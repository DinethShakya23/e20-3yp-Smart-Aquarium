const WebSocket = require('ws');
const mqtt = require('mqtt');
const { TemperatureReading } = require('../models'); 

const server = new WebSocket.Server({ host: '0.0.0.0', port: 8081 });

// Configuration
const MQTT_BROKER = '192.168.254.46'; // MQTT Broker IP
const MQTT_PORT = 1883;
const MQTT_TOPIC_SENSOR = 'sensor/data';
const MQTT_TOPIC_FEED = 'feeder/control'; // New topic for feeding control

const mqttClient = mqtt.connect(`mqtt://${MQTT_BROKER}:${MQTT_PORT}`);

// Store the latest sensor data
let latestSensorData = {
    temperature: null,
    pH: null,
    turbidity: null,
};

// Store feeding schedule
let feedingSchedule = {
    time: null,
    quantity: null
};

// Connect to MQTT broker
mqttClient.on('connect', () => {
    console.log('✅ Connected to MQTT broker');

    // Subscribe to sensor data
    mqttClient.subscribe(MQTT_TOPIC_SENSOR, (err) => {
        if (err) console.error('❌ Failed to subscribe to sensor topic:', err);
        else console.log(`:📡 Subscribed to MQTT topic: ${MQTT_TOPIC_SENSOR}`);
    });
});

mqttClient.on('error', (err) => {
    console.error('❌ MQTT Connection Error:', err);
});

// Handle incoming MQTT sensor data
mqttClient.on('message', async (topic, message) => {
    try {
        const data = JSON.parse(message.toString());

        if (topic === MQTT_TOPIC_SENSOR) {
            if (data.pH && data.temperature && data.turbidity) {
                console.log(`📡 Received Sensor Data: pH=${data.pH}, turbidity=${data.turbidity}, temperature=${data.temperature}`);

                const now = new Date();
                const date = now.toISOString().slice(0, 10); // YYYY-MM-DD
                const time = now.toTimeString().slice(0, 8);  // HH:MM:SS

                // Store in DB
                await TemperatureReading.create({
                    date,
                    time,
                    temperature: parseFloat(data.temperature)
                });

                // Update in-memory latest data
                latestSensorData.pH = parseFloat(data.pH);
                latestSensorData.turbidity = parseFloat(data.turbidity);
                latestSensorData.temperature = parseFloat(data.temperature);

                // Send to connected WebSocket clients
                server.clients.forEach(client => {
                    if (client.readyState === WebSocket.OPEN) {
                        client.send(JSON.stringify({ type: "sensor", data: latestSensorData }));
                    }
                });
            } else {
                console.warn('⚠ Incomplete sensor data received:', data);
            }
        }
    } catch (error) {
        console.error('❌ Error parsing MQTT message:', error);
    }
});


// Handle WebSocket connections
server.on('connection', (socket) => {
    console.log('🔗 Client connected');

    // Send latest sensor data on new connection
    if (latestSensorData.pH !== null) {
        socket.send(JSON.stringify({ type: "sensor", data: latestSensorData }));
    }

    // Listen for messages (Feeding Schedule)
    socket.on('message', (message) => {
        try {
            const receivedData = JSON.parse(message);

            if (receivedData.time && receivedData.quantity) {
                console.log(`📩 Received Feeding Schedule: Time=${receivedData.time}, Quantity=${receivedData.quantity}`);
                // Store feeding schedule
                feedingSchedule.time = receivedData.time;
                feedingSchedule.quantity = receivedData.quantity;

                // Publish feeding schedule to MQTT (Raspberry Pi)
                mqttClient.publish(MQTT_TOPIC_FEED, JSON.stringify(feedingSchedule));
                console.log(`📤 Sent Feeding Command to MQTT: ${JSON.stringify(feedingSchedule)}`);

                // Send confirmation back to Flutter
                socket.send(JSON.stringify({ status: "success", message: "Feeding schedule received successfully" }));
            } else {
                console.warn('⚠️ Incomplete feeding schedule received:', receivedData);
            }
        } catch (error) {
            console.error('❌ Error parsing WebSocket message:', error);
        }
    });

    socket.on('close', () => {
        console.log('❌ Client disconnected');
    });
});

console.log('🚀 WebSocket server running on ws://0.0.0.0:8081');