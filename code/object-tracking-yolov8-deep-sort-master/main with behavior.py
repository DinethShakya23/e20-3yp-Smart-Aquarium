import os
import cv2
import time
import threading
import random
import queue
import numpy as np
from ultralytics import YOLO
from tracker import Tracker
from deep_sort.deep_sort.tracker import Tracker as DeepSortTracker
from deep_sort.deep_sort.detection import Detection
from deep_sort.deep_sort import nn_matching
from deep_sort.tools import generate_detections as gdet

# WebSocket server
from websocket_server_local import start_server, send_to_clients
import threading
import asyncio


# 🛠️ Wrap coroutine in a function that runs the event loop
ws_loop = asyncio.new_event_loop()

def run_ws_server():
    asyncio.set_event_loop(ws_loop)
    ws_loop.run_until_complete(start_server())

# Start the WebSocket server in a background thread
ws_thread = threading.Thread(target=run_ws_server, daemon=True)
ws_thread.start()


frame_queue = queue.Queue(maxsize=1)

# Lucas-Kanade Optical Flow Parameters
lk_params = dict(winSize=(15, 15), maxLevel=2,
                 criteria=(cv2.TERM_CRITERIA_EPS | cv2.TERM_CRITERIA_COUNT, 10, 0.03))

# Kalman Filter
class KalmanFilterTracker:
    def __init__(self):
        self.kf = cv2.KalmanFilter(4, 2)
        self.kf.transitionMatrix = np.array([[1, 0, 1, 0],
                                             [0, 1, 0, 1],
                                             [0, 0, 1, 0],
                                             [0, 0, 0, 1]], dtype=np.float32)
        self.kf.measurementMatrix = np.array([[1, 0, 0, 0],
                                              [0, 1, 0, 0]], dtype=np.float32)
        self.kf.processNoiseCov = np.eye(4, dtype=np.float32) * 0.03
        self.kf.measurementNoiseCov = np.eye(2, dtype=np.float32) * 0.1
        self.kf.errorCovPost = np.eye(4, dtype=np.float32)

    def predict(self):
        return self.kf.predict()

    def update(self, x, y):
        self.kf.correct(np.array([[np.float32(x)], [np.float32(y)]]))

    def get_state(self):
        return self.kf.statePost

# Helper Functions
def compare_histograms(hist1, hist2):
    return cv2.compareHist(hist1, hist2, cv2.HISTCMP_CORREL)

# Initialize models
model = YOLO("best.pt")
encoder = gdet.create_box_encoder("model_data/mars-small128.pb", batch_size=1)
metric = nn_matching.NearestNeighborDistanceMetric("cosine", 0.4, None)
deep_tracker = DeepSortTracker(metric, max_age=30, n_init=3)

kalman_filter_dict = {}
fish_paths = {}
track_colors = {}
last_alert_times = {}
total_time_tracker = {}
surface_time_tracker = {}
alert_cooldown = 10

prev_gray = None
prev_points = None

# Behavior monitoring
stationary_tracker = {}   # track_id: (last_position, stationary_time)
surface_stay_tracker = {}   # track_id: [timestamps at surface]

# Thread 1: Capture
def capture_frames(video_url):
    global frame_queue
    cap = cv2.VideoCapture(video_url)
    while cap.isOpened():
        ret, frame = cap.read()
        if not ret:
            break
        if frame_queue.full():
            frame_queue.get_nowait()
        frame_queue.put(frame)
    cap.release()

# Thread 2: Process
def process_frames():
    global prev_gray, prev_points
    cv2.namedWindow("Fish Tracking (Multithreaded)", cv2.WINDOW_NORMAL)
    cv2.resizeWindow("Fish Tracking (Multithreaded)", 800, 600)

    while True:
        if frame_queue.empty():
            time.sleep(0.01)
            continue

        frame = frame_queue.get()
        gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
        h, w = frame.shape[:2]
        surface_threshold = int(h * 0.2)

        results = model(frame, conf=0.4, iou=0.3)
        detections = []

        for result in results:
            for r in result.boxes.data.tolist():
                x1, y1, x2, y2, score, class_id = r
                if score > 0.5:
                    detections.append([int(x1), int(y1), int(x2), int(y2), score])

        if detections:
            bboxes = np.array([d[:-1] for d in detections])
            bboxes[:, 2:] -= bboxes[:, 0:2]
            scores = [d[-1] for d in detections]
            features = encoder(frame, bboxes)
            dets = [Detection(bbox, scores[i], features[i]) for i, bbox in enumerate(bboxes)]
            deep_tracker.predict()
            deep_tracker.update(dets)
        else:
            deep_tracker.predict()
            deep_tracker.update([])

        for track in deep_tracker.tracks:
            if not track.is_confirmed() or track.time_since_update > 1:
                continue

            x1, y1, x2, y2 = track.to_tlbr()
            track_id = track.track_id
            cx, cy = int((x1 + x2) / 2), int((y1 + y2) / 2)

            # Kalman Filter
            if track_id not in kalman_filter_dict:
                kalman_filter_dict[track_id] = KalmanFilterTracker()
            if track.time_since_update == 0:
                kalman_filter_dict[track_id].update(x1, y1)
            else:
                kalman_filter_dict[track_id].predict()

            # Path history
            if track_id not in fish_paths:
                fish_paths[track_id] = []
            fish_paths[track_id].append((cx, cy))
            if len(fish_paths[track_id]) > 50:
                fish_paths[track_id].pop(0)

            # -------- Behavior Detection --------
            # 1. Stationary Detection
            current_time = time.time()
            if track_id not in stationary_tracker:
                stationary_tracker[track_id] = ((cx, cy), current_time)
            else:
                (prev_cx, prev_cy), start_time = stationary_tracker[track_id]
                if np.linalg.norm(np.array([cx - prev_cx, cy - prev_cy])) < 10:
                    if current_time - start_time > 1:  # 1 second threshold for being stationary

                        # Check cooldown for sending alert
                        alert_key = (track_id, "STRESSED")
                        last_sent = last_alert_times.get(alert_key, 0)
                        if current_time - last_sent > alert_cooldown:
                            last_alert_times[alert_key] = current_time

                            cv2.putText(frame, "STRESSED?", (int(x1), int(y2) + 15),
                                        cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 0, 255), 2)

                            # Send to WebSocket client only once per cooldown period
                            alert = {
                                "track_id": track_id,
                                "type": "STRESSED",
                                "position": {"x": cx, "y": cy},
                                "timestamp": current_time
                            }
                            asyncio.run_coroutine_threadsafe(send_to_clients(alert), ws_loop)

                else:
                    stationary_tracker[track_id] = ((cx, cy), current_time)
            """
            # 2. Surfacing Detection
            if cy < surface_threshold:
                if track_id not in surface_stay_tracker:
                    surface_stay_tracker[track_id] = ((cx, cy), current_time)
                else:
                    (prev_cx, prev_cy), start_time = surface_stay_tracker[track_id]
                    if np.linalg.norm(np.array([cx - prev_cx, cy - prev_cy])) < 10:
                        if current_time - start_time > 1:
                            alert_key = (track_id, "LOW_OXYGEN")
                            last_sent = last_alert_times.get(alert_key, 0)
                            if current_time - last_sent > alert_cooldown:
                                last_alert_times[alert_key] = current_time

                                cv2.putText(frame, "LOW OXYGEN!", (int(x1), int(y2) + 50),
                                            cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 0, 255), 2)

                                # 🟢 SEND TO WEBSOCKET CLIENT (Flutter)
                                alert = {
                                    "track_id": track_id,
                                    "type": "LOW_OXYGEN",
                                    "position": {"x": cx, "y": cy},
                                    "timestamp": current_time
                                }
                                asyncio.run_coroutine_threadsafe(send_to_clients(alert), ws_loop)
                    else:
                        surface_stay_tracker[track_id] = ((cx, cy), current_time)
            else:
                if track_id in surface_stay_tracker:
                    del surface_stay_tracker[track_id]
            """
            # --- Behavior: Surfacing Detection ---
            if track_id not in total_time_tracker:
                total_time_tracker[track_id] = 0.0
                surface_time_tracker[track_id] = 0.0

            frame_duration = 1 / 30  # duration of one frame in seconds, set this accordingly

            # Update total observed time for the fish
            total_time_tracker[track_id] += frame_duration

            if cy < surface_threshold:
                # Update surface time if fish is near surface
                surface_time_tracker[track_id] += frame_duration

                # Now check if fish spent over 90% of time near surface
                surface_ratio = surface_time_tracker[track_id] / total_time_tracker[track_id]
                if surface_ratio > 0.9:
                    alert_key = (track_id, "LOW_OXYGEN")
                    last_sent = last_alert_times.get(alert_key, 0)
                    if current_time - last_sent > alert_cooldown:
                        last_alert_times[alert_key] = current_time

                        cv2.putText(frame, "LOW OXYGEN!", (int(x1), int(y2) + 50),
                                    cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 0, 255), 2)

                        alert = {
                                "track_id": track_id,
                                "type": "LOW_OXYGEN",
                                "position": {"x": cx, "y": cy},
                                "timestamp": current_time
                        }
                        asyncio.run_coroutine_threadsafe(send_to_clients(alert), ws_loop)

            else:
                # Reset surface tracking if fish not near surface
                surface_time_tracker[track_id] = 0.0
                total_time_tracker[track_id] = 0.0
            
            # Draw tracking box
            if track_id not in track_colors:
                track_colors[track_id] = (random.randint(0, 255),
                                          random.randint(0, 255),
                                          random.randint(0, 255))
            color = track_colors[track_id]
            cv2.rectangle(frame, (int(x1), int(y1)), (int(x2), int(y2)), color, 2)
            cv2.putText(frame, f"ID: {track_id}", (int(x1), int(y1)-10),
                        cv2.FONT_HERSHEY_SIMPLEX, 0.5, color, 2)

            # Draw movement path
            if len(fish_paths[track_id]) > 1:
                cv2.polylines(frame, [np.array(fish_paths[track_id], np.int32)],
                              False, color, 2)

        # Optical flow update
        if prev_points is not None and len(prev_points) > 0:
            new_points, status, _ = cv2.calcOpticalFlowPyrLK(prev_gray, gray, prev_points, None, **lk_params)
            prev_points = new_points.reshape(-1, 1, 2)
            prev_gray = gray.copy()
        else:
            prev_gray = gray.copy()

        cv2.imshow("Fish Tracking (Multithreaded)", frame)
        if cv2.waitKey(1) & 0xFF == ord('q'):
            break

    cv2.destroyAllWindows()
# Main execution
video_url = "rtsp://192.168.8.132:8554/mystream"
thread1 = threading.Thread(target=capture_frames, args=(video_url,))
thread2 = threading.Thread(target=process_frames)

thread1.start()
thread2.start()
thread1.join()
thread2.join()
