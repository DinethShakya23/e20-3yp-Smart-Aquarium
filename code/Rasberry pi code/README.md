# AquaSense Raspberry Pi Hardware Control

Python scripts for hardware control and sensor reading on Raspberry Pi for the AquaSense Smart Aquarium system.

## Overview

This component handles:
- 📡 Reading sensor data (pH, temperature, turbidity)
- 🌡️ Temperature control (heating/cooling via Peltier module)
- 🐟 Automated fish feeding (servo motor control)
- 📷 Camera streaming for fish monitoring
- 🔄 MQTT communication with backend server
- ⏰ Scheduled tasks (feeding times)

## Hardware Requirements

### Main Components
- Raspberry Pi 3 Model B+ or higher
- MicroSD card (16GB minimum, Class 10)
- 5V 2.5A power supply for Raspberry Pi
- 12V 5A power supply for actuators

### Sensors
- Gravity Analog pH Sensor
- DS18B20 Waterproof Digital Temperature Sensor
- DFRobot Gravity Analog Turbidity Sensor
- ADS1115 16-Bit ADC (for analog sensors)

### Actuators & Control
- Peltier Module TEC1-12706 (temperature control)
- Cooling Fan 4010 Axial 40x40x10mm 5V
- Servo Motor SG90 (fish feeder)
- Double BTS7960B DC Motor Driver H-Bridge PWM

### Additional Components
- DS3231 Precision RTC Module
- Raspberry Pi Camera V2.1
- Aluminum heatsinks and water blocks
- Jumper wires and breadboard

## Software Prerequisites

### Operating System
- Raspberry Pi OS (Raspbian Buster or later)
- Python 3.7 or higher

### System Packages
```bash
sudo apt-get update
sudo apt-get install -y python3-pip python3-dev
sudo apt-get install -y i2c-tools python3-smbus
sudo apt-get install -y git
```

### Enable Required Interfaces
```bash
# Enable I2C, 1-Wire, Camera
sudo raspi-config
# Navigate to: Interface Options
# Enable: I2C, 1-Wire, Camera
```

Reboot after enabling:
```bash
sudo reboot
```

## Installation

### 1. Extract Code

```bash
cd code/Rasberry\ pi\ code/
7z x "Rasberry pi code.7z"
```

If 7z is not installed:
```bash
sudo apt-get install p7zip-full
```

### 2. Install Python Dependencies

```bash
pip3 install RPi.GPIO
pip3 install adafruit-circuitpython-ads1x15
pip3 install paho-mqtt
pip3 install w1thermsensor
pip3 install python-dotenv
pip3 install schedule
```

Or install from requirements.txt (if available):
```bash
pip3 install -r requirements.txt
```

### 3. Configure Environment

Create a `.env` file with configuration:

```env
# MQTT Configuration
MQTT_BROKER=mqtt://backend_server_ip:1883
MQTT_CLIENT_ID=aquasense_rpi_001
MQTT_USERNAME=
MQTT_PASSWORD=

# Device Configuration
DEVICE_ID=aquarium_001
FEED_SCHEDULE=08:00,18:00
FEED_DURATION=2

# Sensor Thresholds
TEMP_MIN=24.0
TEMP_MAX=28.0
PH_MIN=6.5
PH_MAX=7.5
TURBIDITY_MAX=25.0

# Update Intervals (seconds)
SENSOR_READ_INTERVAL=60
DATA_PUBLISH_INTERVAL=300
```

## GPIO Pin Configuration

### Pin Assignments

```python
# Temperature Sensor (1-Wire)
TEMP_SENSOR_PIN = 4  # GPIO4 (Pin 7)

# Servo Motor (Fish Feeder)
SERVO_PIN = 18  # GPIO18 (Pin 12) - PWM capable

# Peltier Module Control (via Motor Driver)
PELTIER_ENABLE = 23  # GPIO23 (Pin 16)
PELTIER_FORWARD = 24  # GPIO24 (Pin 18) - Heating
PELTIER_REVERSE = 25  # GPIO25 (Pin 22) - Cooling

# Cooling Fan
FAN_PIN = 17  # GPIO17 (Pin 11)

# I2C (for ADS1115 - pH and Turbidity sensors)
# SDA = GPIO2 (Pin 3)
# SCL = GPIO3 (Pin 5)

# Status LED (optional)
STATUS_LED = 27  # GPIO27 (Pin 13)
```

### Wiring Diagram Reference

See `docs/images/hardware*.PNG` for detailed wiring diagrams.

## Project Structure

```
Rasberry pi code/
├── main.py                    # Main entry point
├── sensors/
│   ├── temperature.py         # DS18B20 temperature sensor
│   ├── ph_sensor.py          # pH sensor via ADS1115
│   ├── turbidity.py          # Turbidity sensor via ADS1115
│   └── sensor_manager.py     # Sensor reading coordinator
├── actuators/
│   ├── servo_feeder.py       # Servo motor control for feeding
│   ├── peltier_control.py    # Temperature control
│   └── fan_control.py        # Cooling fan control
├── mqtt/
│   ├── mqtt_client.py        # MQTT connection and publishing
│   └── mqtt_handlers.py      # Message handlers
├── utils/
│   ├── config.py             # Configuration loader
│   ├── logger.py             # Logging setup
│   └── scheduler.py          # Task scheduling
├── camera/
│   └── camera_stream.py      # RTSP camera streaming
├── requirements.txt           # Python dependencies
├── .env.example              # Environment template
└── README.md
```

## Running the System

### Start All Services

```bash
cd code/Rasberry\ pi\ code/
python3 main.py
```

### Run as Background Service

Create systemd service file `/etc/systemd/system/aquasense.service`:

```ini
[Unit]
Description=AquaSense Hardware Control
After=network.target

[Service]
Type=simple
User=pi
WorkingDirectory=/home/pi/e20-3yp-Smart-Aquarium/code/Rasberry pi code
ExecStart=/usr/bin/python3 /home/pi/e20-3yp-Smart-Aquarium/code/Rasberry pi code/main.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

Enable and start service:
```bash
sudo systemctl enable aquasense
sudo systemctl start aquasense
sudo systemctl status aquasense
```

View logs:
```bash
sudo journalctl -u aquasense -f
```

## Testing

### Test Individual Components

#### Test Temperature Sensor
```bash
python3 -c "from sensors.temperature import TemperatureSensor; t = TemperatureSensor(); print(f'Temperature: {t.read()}°C')"
```

#### Test Servo Motor
```bash
python3 -c "from actuators.servo_feeder import ServoFeeder; s = ServoFeeder(); s.feed()"
```

#### Test I2C Devices
```bash
sudo i2cdetect -y 1
```
Should show ADS1115 at address 0x48

#### Test 1-Wire Devices
```bash
ls /sys/bus/w1/devices/
```
Should show temperature sensor (28-xxxxxxxxxxxx)

### Test MQTT Connection
```bash
python3 -c "from mqtt.mqtt_client import MQTTClient; c = MQTTClient(); c.connect(); c.publish_test()"
```

## Camera Streaming

### Setup RTSP Server

Install required packages:
```bash
sudo apt-get install vlc
```

### Stream Camera
```bash
raspivid -o - -t 0 -w 640 -h 480 -fps 15 | cvlc -vvv stream:///dev/stdin --sout '#rtp{sdp=rtsp://:8554/stream}' :demux=h264
```

Or use the provided script:
```bash
python3 camera/camera_stream.py
```

## Sensor Calibration

### pH Sensor Calibration
1. Prepare pH 4.0 and pH 7.0 buffer solutions
2. Run calibration script:
```bash
python3 sensors/calibrate_ph.py
```
3. Follow on-screen instructions

### Temperature Sensor
DS18B20 is pre-calibrated. Verify accuracy:
```bash
python3 sensors/test_temperature.py
```

### Turbidity Sensor
1. Use distilled water as reference (0 NTU)
2. Run calibration:
```bash
python3 sensors/calibrate_turbidity.py
```

## MQTT Topics

### Publishing (from Raspberry Pi)
- `aquasense/sensors/data` - Sensor readings
  ```json
  {
    "deviceId": "aquarium_001",
    "temperature": 25.5,
    "pH": 7.2,
    "turbidity": 15.3,
    "timestamp": "2024-01-17T10:30:00Z"
  }
  ```

- `aquasense/alerts` - System alerts
  ```json
  {
    "deviceId": "aquarium_001",
    "alertType": "temperature_high",
    "value": 29.5,
    "threshold": 28.0,
    "timestamp": "2024-01-17T10:30:00Z"
  }
  ```

### Subscribing (to Raspberry Pi)
- `aquasense/control/feed` - Feed fish command
  ```json
  {
    "deviceId": "aquarium_001",
    "amount": 1
  }
  ```

- `aquasense/control/temp` - Set target temperature
  ```json
  {
    "deviceId": "aquarium_001",
    "targetTemp": 26.0
  }
  ```

## Troubleshooting

### Sensor Not Detected

#### I2C Issues
```bash
# Check I2C is enabled
sudo raspi-config
# Enable I2C interface

# Scan I2C bus
sudo i2cdetect -y 1

# Check permissions
sudo usermod -a -G i2c pi
```

#### 1-Wire Issues
```bash
# Check 1-Wire is enabled
sudo modprobe w1-gpio
sudo modprobe w1-therm

# Add to /boot/config.txt
dtoverlay=w1-gpio,gpiopin=4

# Reboot
sudo reboot
```

### GPIO Permission Errors
```bash
sudo usermod -a -G gpio pi
sudo reboot
```

### MQTT Connection Failed
- Verify broker IP address and port
- Check firewall rules
- Test with mosquitto client:
```bash
sudo apt-get install mosquitto-clients
mosquitto_pub -h <broker_ip> -t test -m "hello"
```

### Servo Not Moving
- Check power supply (servos need stable 5V)
- Verify PWM pin (use hardware PWM pins: GPIO12, 13, 18, 19)
- Test servo separately

### Camera Not Working
```bash
# Enable camera
sudo raspi-config
# Interface Options -> Camera -> Enable

# Test camera
raspistill -o test.jpg

# Check camera module
vcgencmd get_camera
```

## Performance Optimization

### Reduce CPU Usage
- Adjust sensor read intervals
- Optimize image processing
- Use hardware PWM for servo control

### Improve Reliability
- Add error handling and retries
- Implement watchdog timer
- Log errors for debugging

### Power Management
- Use separate power supply for motors
- Add capacitors for voltage stabilization
- Monitor current draw

## Maintenance

### Regular Tasks
- Check sensor calibration monthly
- Clean sensors quarterly
- Verify GPIO connections
- Update software dependencies
- Check system logs

### Backup Configuration
```bash
# Backup configuration
cp .env .env.backup

# Backup scripts
tar -czf aquasense_backup.tar.gz .
```

## Safety Considerations

⚠️ **Important Safety Notes**
- Keep electrical components away from water
- Use waterproof enclosures for submerged sensors
- Ensure proper grounding
- Use appropriate power supplies
- Never exceed component voltage/current ratings
- Monitor temperature of Peltier module and heatsinks

## Resources

- [Raspberry Pi GPIO Pinout](https://pinout.xyz/)
- [RPi.GPIO Documentation](https://sourceforge.net/p/raspberry-gpio-python/wiki/Home/)
- [Adafruit ADS1x15 Guide](https://learn.adafruit.com/adafruit-4-channel-adc-breakouts)
- [DS18B20 Sensor Guide](https://www.raspberrypi-spy.co.uk/2013/03/raspberry-pi-1-wire-digital-thermometer-sensor/)

## Support

For hardware-related issues:
- Check wiring connections
- Verify component specifications
- Review system logs
- Contact development team

## License

Part of the AquaSense project - University of Peradeniya
