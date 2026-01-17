# AquaSense Fish Detection & Tracking

YOLOv8 object detection + Deep SORT tracking system for monitoring fish behavior in the AquaSense Smart Aquarium.

[![Watch the video](https://img.youtube.com/vi/jIRRuGN0j5E/0.jpg)](https://www.youtube.com/watch?v=jIRRuGN0j5E)

## Overview

This component provides:
- 🐟 Real-time fish detection using YOLOv8
- 📍 Multi-fish tracking with Deep SORT algorithm
- 📊 Behavior analysis (movement patterns, activity levels)
- 🚨 Abnormal behavior detection
- 📹 Video stream processing from Raspberry Pi camera

## Features

- Detect and track multiple fish simultaneously
- Count fish in the aquarium
- Analyze fish movement patterns
- Detect abnormal behaviors (erratic movement, lethargy)
- Generate alerts for potential health issues
- Video recording with tracking overlay

## Prerequisites

### System Requirements
- **Python** 3.7 or higher
- **CUDA** (optional, for GPU acceleration)
- At least 4GB RAM
- GPU with 2GB+ VRAM (recommended for real-time processing)

### Software Dependencies
- OpenCV
- YOLOv8 (ultralytics)
- TensorFlow 2.x
- Deep SORT implementation
- NumPy, scikit-learn, scikit-image

## Installation

### 1. Install Python Dependencies

```bash
cd code/object-tracking-yolov8-deep-sort-master
pip install -r requirements.txt
```

This installs:
- `ultralytics==8.0.33` - YOLOv8 framework
- `scikit-learn==0.21.0` - Machine learning utilities
- `tensorflow==2.11.0` - Deep learning framework
- `scikit-image==0.19.3` - Image processing
- `filterpy==1.4.5` - Kalman filtering for tracking

### 2. Download Model Weights

#### YOLOv8 Model
YOLOv8 model will be automatically downloaded on first run. To use a custom trained model:
```bash
# Download pre-trained weights
wget https://github.com/ultralytics/assets/releases/download/v0.0.0/yolov8n.pt

# Or train your own model (see Training section)
```

#### Deep SORT Feature Extractor
Download the Deep SORT feature extraction model:
- [Download from Google Drive](https://drive.google.com/file/d/18fKzfqnqhqW3s9zwsCbnVJ5XF2JFeqMp/view?usp=sharing)

Place the downloaded model in:
```
deep_sort/model_data/mars-small128.pb
```

### 3. Prepare Training Data (Optional)

If using custom fish detection:
- [Download sample data from Google Drive](https://drive.google.com/drive/folders/1kZ0QVwlwMERyTyi5c72GeqKgr8qAUx2o?usp=sharing)

Or prepare your own dataset:
```
data/
├── images/
│   ├── train/
│   ├── val/
│   └── test/
└── labels/
    ├── train/
    ├── val/
    └── test/
```

## Configuration

### config.yaml

Create or edit `config.yaml`:

```yaml
# Model Configuration
model:
  weights: 'yolov8n.pt'
  confidence: 0.5
  iou_threshold: 0.45
  img_size: 640

# Deep SORT Configuration
deepsort:
  model_path: 'deep_sort/model_data/mars-small128.pb'
  max_cosine_distance: 0.3
  nn_budget: 100
  max_age: 70
  n_init: 3

# Video Configuration
video:
  source: 'rtsp://raspberry_pi_ip:8554/stream'
  fps: 15
  width: 640
  height: 480

# Behavior Analysis
behavior:
  min_movement_threshold: 5  # pixels
  max_movement_threshold: 100  # pixels
  inactivity_timeout: 300  # seconds
  
# Alert Configuration
alerts:
  enable: true
  mqtt_broker: 'mqtt://backend_ip:1883'
  topic: 'aquasense/alerts/behavior'
```

## Usage

### Basic Usage

#### From Video File
```bash
python main.py --video path/to/video.mp4
```

#### From Webcam
```bash
python main.py --source 0
```

#### From RTSP Stream (Raspberry Pi Camera)
```bash
python main.py --source rtsp://192.168.1.100:8554/stream
```

### Advanced Options

```bash
python main.py \
  --source rtsp://192.168.1.100:8554/stream \
  --weights yolov8n.pt \
  --conf-thres 0.5 \
  --iou-thres 0.45 \
  --save-vid \
  --save-txt \
  --classes 0  # 0 for fish class
```

### Command Line Arguments

- `--source` - Video source (file, webcam index, RTSP URL)
- `--weights` - Path to YOLOv8 weights file
- `--conf-thres` - Confidence threshold for detections (0-1)
- `--iou-thres` - IOU threshold for NMS
- `--img-size` - Inference size (pixels)
- `--save-vid` - Save output video with tracking
- `--save-txt` - Save tracking results to text file
- `--classes` - Filter by class (0 for fish)
- `--device` - CUDA device (0, 1, 2, ...) or 'cpu'
- `--view-img` - Display tracking results
- `--no-trace` - Don't show tracking traces

## Project Structure

```
object-tracking-yolov8-deep-sort-master/
├── main.py                    # Main tracking script
├── detect.py                  # Detection module
├── tracker.py                 # Tracking coordination
├── deep_sort/                 # Deep SORT implementation
│   ├── deep_sort.py
│   ├── detection.py
│   ├── tracker.py
│   ├── nn_matching.py
│   ├── kalman_filter.py
│   └── model_data/
│       └── mars-small128.pb   # Feature extractor model
├── utils/
│   ├── datasets.py            # Dataset loading
│   ├── general.py             # Utility functions
│   └── plots.py               # Visualization
├── behavior_analysis/
│   ├── movement_analyzer.py   # Movement pattern analysis
│   └── alert_generator.py     # Behavior alerts
├── config.yaml                # Configuration file
├── requirements.txt           # Python dependencies
└── README.md
```

## Training Custom Model

### Prepare Dataset

1. Collect fish images/videos
2. Annotate using [CVAT](https://github.com/opencv/cvat) or [LabelImg](https://github.com/heartexlabs/labelImg)
3. Export in YOLO format

### Train YOLOv8

```bash
# Create dataset.yaml
cat > dataset.yaml << EOF
path: ./data
train: images/train
val: images/val
nc: 1  # number of classes
names: ['fish']
EOF

# Train model
yolo train \
  model=yolov8n.pt \
  data=dataset.yaml \
  epochs=100 \
  imgsz=640 \
  batch=16
```

### Evaluate Model

```bash
yolo val \
  model=runs/train/exp/weights/best.pt \
  data=dataset.yaml
```

## Behavior Analysis

### Movement Patterns

The system analyzes:
- **Velocity**: Average speed of fish movement
- **Trajectory**: Path patterns (straight, circular, erratic)
- **Activity Level**: Active vs. inactive periods
- **Group Behavior**: Schooling patterns

### Abnormal Behavior Detection

Alerts generated for:
- Excessive inactivity (possible illness)
- Erratic movement (stress, aggression)
- Surface gasping (low oxygen)
- Hiding behavior (environmental stress)
- Abnormal swimming patterns

### Alert Example

```json
{
  "timestamp": "2024-01-17T10:30:00Z",
  "fish_id": 3,
  "alert_type": "low_activity",
  "details": {
    "movement_score": 0.15,
    "duration_seconds": 450,
    "normal_range": [0.4, 0.8]
  }
}
```

## Integration with AquaSense

### MQTT Communication

Send behavior alerts to backend:
```python
import paho.mqtt.client as mqtt

client = mqtt.Client()
client.connect("backend_ip", 1883, 60)

alert_data = {
    "type": "behavior_alert",
    "fish_count": 5,
    "abnormal_behavior": True,
    "details": "Low activity detected"
}

client.publish("aquasense/alerts/behavior", json.dumps(alert_data))
```

### REST API Integration

```python
import requests

response = requests.post(
    "http://backend_ip:3001/api/behavior/alert",
    json=alert_data,
    headers={"Authorization": "Bearer <token>"}
)
```

## Performance Optimization

### GPU Acceleration

Ensure CUDA is properly installed:
```bash
python -c "import torch; print(torch.cuda.is_available())"
```

Run with GPU:
```bash
python main.py --device 0  # Use first GPU
```

### CPU Optimization

For CPU-only systems:
- Use smaller model: `yolov8n.pt` (nano)
- Reduce input size: `--img-size 416`
- Lower FPS: Process every Nth frame
- Disable visualization: Remove `--view-img`

### Raspberry Pi Optimization

For edge deployment:
- Use TensorFlow Lite model
- Reduce resolution to 416x416
- Process at 5-10 FPS
- Use hardware acceleration (Coral TPU)

## Troubleshooting

### Model Not Loading
```bash
# Clear cache and redownload
rm -rf ~/.cache/torch/hub/ultralytics_yolov8*
python main.py  # Will redownload
```

### CUDA Out of Memory
- Reduce batch size
- Use smaller model (yolov8n instead of yolov8x)
- Reduce image size: `--img-size 416`

### Low FPS
- Enable GPU acceleration
- Reduce input resolution
- Use lighter model
- Process every Nth frame

### Detection Issues
- Adjust confidence threshold: `--conf-thres 0.3`
- Check lighting conditions
- Clean camera lens
- Retrain model with aquarium-specific data

### RTSP Stream Connection Failed
```bash
# Test stream with VLC or ffplay
ffplay rtsp://192.168.1.100:8554/stream

# Check network connectivity
ping 192.168.1.100
```

## Evaluation Metrics

### Detection Performance
- **mAP** (mean Average Precision)
- **Precision**: True positives / (True positives + False positives)
- **Recall**: True positives / (True positives + False negatives)

### Tracking Performance
- **MOTA** (Multiple Object Tracking Accuracy)
- **IDF1** (ID F1 Score)
- **Track Fragmentation**

## Resources

### Documentation
- [YOLOv8 Documentation](https://docs.ultralytics.com/)
- [Deep SORT Paper](https://arxiv.org/abs/1703.07402)
- [Original Deep SORT Implementation](https://github.com/nwojke/deep_sort)

### Datasets
- [Fish4Knowledge Dataset](http://groups.inf.ed.ac.uk/f4k/)
- [Sample Aquarium Training Data](https://drive.google.com/drive/folders/1kZ0QVwlwMERyTyi5c72GeqKgr8qAUx2o?usp=sharing)

### Related Work
- [Fish Detection and Tracking](https://github.com/computervisiondeveloper/deep_sort)
- [Aquaculture Monitoring](https://www.mdpi.com/2077-1312/9/10/1088)

## Contributing

Improvements welcome:
- Better fish detection models
- Advanced behavior analysis algorithms
- Performance optimizations
- Bug fixes

## Support

For object tracking issues:
- Check GPU/CUDA installation
- Verify model files are downloaded
- Test with sample videos
- Review configuration parameters
- Contact development team

## License

Part of the AquaSense project - University of Peradeniya

Based on:
- [YOLOv8](https://github.com/ultralytics/ultralytics) - AGPL-3.0
- [Deep SORT](https://github.com/nwojke/deep_sort) - GPL-3.0
