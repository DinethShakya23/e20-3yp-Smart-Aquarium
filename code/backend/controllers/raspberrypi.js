const WebSocket = require('ws');
const mqtt = require('mqtt');

const server = new WebSocket.Server({ host: '0.0.0.0', port: 8081 });

// Configuration
const MQTT_BROKER = '13.53.127.196'; // MQTT Broker IP
const MQTT_PORT = 1883;
const MQTT_TOPIC_SENSOR = 'sensor/data';
const MQTT_TOPIC_FEED = 'feeder/control'; // New topic for feeding control

const mqttClient = mqtt.connect(`mqtt://${MQTT_BROKER}:${MQTT_PORT}`);

// Store the latest sensor data
let latestSensorData = {
    temp: null,
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
        else console.log(`📡 Subscribed to MQTT topic: ${MQTT_TOPIC_SENSOR}`);
    });
});

mqttClient.on('error', (err) => {
    console.error('❌ MQTT Connection Error:', err);
});

// Handle incoming MQTT sensor data
mqttClient.on('message', (topic, message) => {
    try {
        const data = JSON.parse(message.toString());

        if (topic === MQTT_TOPIC_SENSOR) {
            if (data.pH) {
                console.log(`📡 Received Sensor Data: pH=${data.pH}, turbidity=${data.turbidity}, temperature=${data.temp}`);

                latestSensorData.pH = parseFloat(data.pH);
                latestSensorData.turbidity = parseFloat(data.turbidity);
                latestSensorData.temp = parseFloat(data.temp);

                // Broadcast updated sensor data to WebSocket clients
                server.clients.forEach(client => {
                    if (client.readyState === WebSocket.OPEN) {
                        client.send(JSON.stringify({ type: "sensor", data: latestSensorData }));
                    }
                });
            } else {
                console.warn('⚠️ Incomplete sensor data received:', data);
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

console.log('🚀 WebSocket server running on ws://13.53.127.196:8081');