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

# Frame queue with 1-slot buffer to always process latest frame
frame_queue = queue.Queue(maxsize=1)

# Lucas-Kanade Optical Flow Parameters
lk_params = dict(winSize=(15, 15), maxLevel=2,
                 criteria=(cv2.TERM_CRITERIA_EPS | cv2.TERM_CRITERIA_COUNT, 10, 0.03))

# Kalman Filter for Predicting Lost Tracks
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

# Histogram Matching Function
def compare_histograms(hist1, hist2):
    return cv2.compareHist(hist1, hist2, cv2.HISTCMP_CORREL)

# Initialize models
model = YOLO("best.pt")
encoder = gdet.create_box_encoder("model_data/mars-small128.pb", batch_size=1)
metric = nn_matching.NearestNeighborDistanceMetric("cosine", 0.4, None)
deep_tracker = DeepSortTracker(metric, max_age=30, n_init=3)
kalman_filter_dict = {}
histograms = {}
fish_paths = {}
track_colors = {}

# Shared vars
prev_gray = None
prev_points = None

# Thread 1: Frame Capture
def capture_frames(video_url):
    global frame_queue
    cap = cv2.VideoCapture(video_url)
    while cap.isOpened():
        ret, frame = cap.read()
        if not ret:
            break
        if not frame_queue.full():
            frame_queue.put(frame)
        else:
            try:
                frame_queue.get_nowait()  # Discard old frame
            except queue.Empty:
                pass
            frame_queue.put(frame)
    cap.release()

# Thread 2: Frame Processing
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

        new_tracks = []
        for track in deep_tracker.tracks:
            if not track.is_confirmed() or track.time_since_update > 1:
                continue
            x1, y1, x2, y2 = track.to_tlbr()
            track_id = track.track_id

            if track_id not in kalman_filter_dict:
                kalman_filter_dict[track_id] = KalmanFilterTracker()

            if track.time_since_update == 0:
                kalman_filter_dict[track_id].update(x1, y1)
                predicted_state = kalman_filter_dict[track_id].get_state()
            else:
                predicted_state = kalman_filter_dict[track_id].predict()

            predicted_x, predicted_y = predicted_state[0][0], predicted_state[1][0]
            new_tracks.append((track_id, (x1, y1, x2, y2), (predicted_x, predicted_y)))

            if track_id not in fish_paths:
                fish_paths[track_id] = []
            fish_paths[track_id].append((int((x1 + x2) / 2), int((y1 + y2) / 2)))
            if len(fish_paths[track_id]) > 50:
                fish_paths[track_id].pop(0)

        # Optical Flow update for lost tracks
        if prev_points is not None and len(prev_points) > 0:
            new_points, status, _ = cv2.calcOpticalFlowPyrLK(prev_gray, gray, prev_points, None, **lk_params)
            for i, track_id in enumerate(kalman_filter_dict.keys()):
                if i >= len(new_points):
                    break
                if deep_tracker.tracks[i].time_since_update > 1:
                    x1, y1 = new_points[i].ravel()
                    kalman_filter_dict[track_id].update(x1, y1)
            prev_gray = gray.copy()
            prev_points = new_points.reshape(-1, 1, 2)
        else:
            prev_gray = gray.copy()

        # Draw Results
        for track_id, (x1, y1, x2, y2), (px, py) in new_tracks:
            if track_id not in track_colors:
                track_colors[track_id] = (random.randint(0, 255), random.randint(0, 255), random.randint(0, 255))
            color = track_colors[track_id]
            cv2.rectangle(frame, (int(x1), int(y1)), (int(x2), int(y2)), color, 2)
            cv2.putText(frame, f"ID: {track_id}", (int(x1), int(y1)-10), cv2.FONT_HERSHEY_SIMPLEX, 0.5, color, 2)

            if len(fish_paths[track_id]) > 1:
                cv2.polylines(frame, [np.array(fish_paths[track_id], np.int32)], False, color, 2)

        cv2.imshow("Fish Tracking (Multithreaded)", frame)
        if cv2.waitKey(1) & 0xFF == ord('q'):
            break

    cv2.destroyAllWindows()

# Start Threads
video_url = "tcp://192.168.8.132:8554"
thread1 = threading.Thread(target=capture_frames, args=(video_url,))
thread2 = threading.Thread(target=process_frames)

thread1.start()
thread2.start()

thread1.join()
thread2.join()
