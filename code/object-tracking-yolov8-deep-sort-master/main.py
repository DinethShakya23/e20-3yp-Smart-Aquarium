import os
import random
import cv2
import numpy as np
from ultralytics import YOLO
from tracker import Tracker
from deep_sort.deep_sort.tracker import Tracker as DeepSortTracker
from deep_sort.deep_sort.detection import Detection
from deep_sort.deep_sort import nn_matching
from deep_sort.tools import generate_detections as gdet

# Lucas-Kanade Optical Flow Parameters
lk_params = dict(winSize=(15, 15), maxLevel=2,
                 criteria=(cv2.TERM_CRITERIA_EPS | cv2.TERM_CRITERIA_COUNT, 10, 0.03))

# Kalman Filter for Predicting Lost Tracks
class KalmanFilterTracker:
    def __init__(self):
        self.kf = cv2.KalmanFilter(4, 2)
        self.kf.transitionMatrix = np.array([[1, 0, 1, 0], [0, 1, 0, 1], [0, 0, 1, 0], [0, 0, 0, 1]], dtype=np.float32)
        self.kf.measurementMatrix = np.array([[1, 0, 0, 0], [0, 1, 0, 0]], dtype=np.float32)
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

# Initialize YOLO and DeepSORT
model = YOLO("best.pt")
encoder = gdet.create_box_encoder("model_data/mars-small128.pb", batch_size=1)
metric = nn_matching.NearestNeighborDistanceMetric("cosine", 0.4, None)
deep_tracker = DeepSortTracker(metric, max_age=30, n_init=3)
kalman_filter_dict = {}
histograms = {}
fish_paths = {}  # Store past positions for tracking paths

# Load Video
video_path = "Fish Swimming Against Dark Background.mp4"
video_out_path = "out.mp4"
cap = cv2.VideoCapture(video_path)
ret, frame = cap.read()
cap_out = cv2.VideoWriter(video_out_path, cv2.VideoWriter_fourcc(*'mp4v'), cap.get(cv2.CAP_PROP_FPS),
                          (frame.shape[1], frame.shape[0]))

# Store Previous Frames for Optical Flow
prev_gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
prev_points = None
track_colors = {} 

while ret:
    gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
    results = model(frame, conf=0.6, iou=0.3)
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
        
        if len(fish_paths[track_id]) > 50:  # Keep the last 50 positions
            fish_paths[track_id].pop(0)

    if prev_points is not None and len(prev_points) > 0:
        new_points, status, _ = cv2.calcOpticalFlowPyrLK(prev_gray, gray, prev_points, None, **lk_params)
    
        for i, track_id in enumerate(kalman_filter_dict.keys()):
            if deep_tracker.tracks[i].time_since_update > 1:
                x1, y1 = new_points[i].ravel()
                kalman_filter_dict[track_id].update(x1, y1)

        prev_gray = gray.copy()
        prev_points = new_points.reshape(-1, 1, 2)
    else:
        prev_gray = gray.copy()
    
    for track_id, (x1, y1, x2, y2), (px, py) in new_tracks:
        if track_id not in track_colors:
            track_colors[track_id] = (random.randint(0, 255), random.randint(0, 255), random.randint(0, 255))
        color = track_colors[track_id]
        cv2.rectangle(frame, (int(x1), int(y1)), (int(x2), int(y2)), color, 2)
        cv2.putText(frame, f"ID: {track_id}", (int(x1), int(y1)-10), cv2.FONT_HERSHEY_SIMPLEX, 0.5, color, 2)
        
        if len(fish_paths[track_id]) > 1:
            cv2.polylines(frame, [np.array(fish_paths[track_id], np.int32)], False, color, 2)
    
    cap_out.write(frame)
    cv2.imshow("Fish Tracking", frame)
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break
    
    ret, frame = cap.read()

cap.release()
cap_out.release()
cv2.destroyAllWindows()
