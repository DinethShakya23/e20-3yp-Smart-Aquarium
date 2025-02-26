const WebSocket = require('ws');
const mqtt = require('mqtt');

const server = new WebSocket.Server({ port: 3002 });

// Configuration
const MQTT_BROKER = '192.168.3.244'; // MQTT Broker IP
const MQTT_PORT = 1883;
const MQTT_TOPIC = 'sensor/data';

const mqttClient = mqtt.connect(`mqtt://${MQTT_BROKER}:${MQTT_PORT}`);

// Store the latest sensor data
let latestSensorData = {
    temp: null, // Will be updated from MQTT
    pH: null, // Will be updated from MQTT
    turbidity: null, // Will be updated from MQTT
};

// Connect to MQTT broker
mqttClient.on('connect', () => {
    console.log('✅ Connected to MQTT broker');
    mqttClient.subscribe(MQTT_TOPIC, (err) => {
        if (err) {
            console.error('❌ Failed to subscribe to topic:', err);
        } else {
            console.log(`📡 Subscribed to MQTT topic: ${MQTT_TOPIC}`);
        }
    });
});

mqttClient.on('error', (err) => {
    console.error('❌ MQTT Connection Error:', err);
});

// Handle incoming MQTT messages
mqttClient.on('message', (topic, message) => {
    try {
        const data = JSON.parse(message.toString());
        if (data.pH) {
            console.log(`📡 Received pH Data: pH=${data.pH} , turbidity=${data.turbidity}, tempature=${data.temp}`);

            // Update only the pH value from MQTT
            latestSensorData.pH = parseFloat(data.pH);
            latestSensorData.turbidity = parseFloat(data.turbidity);
            latestSensorData.temp = parseFloat(data.temp);


            // Broadcast updated data to all WebSocket clients
            server.clients.forEach(client => {
                if (client.readyState === WebSocket.OPEN) {
                    client.send(JSON.stringify(latestSensorData));
                }
            });
        } else {
            console.warn('⚠️ Incomplete data received:', data);
        }
    } catch (error) {
        console.error('❌ Error parsing MQTT message:', error);
    }
});

// Handle WebSocket connections
server.on('connection', (socket) => {
    console.log('🔗 Client connected');

    // Send the latest sensor data immediately upon connection
    if (latestSensorData.pH !== null) {
        socket.send(JSON.stringify(latestSensorData));
    }

    socket.on('message', (message) => {
        console.log('📩 Received:', message);
        socket.send(`Echo: ${message}`);
    });

    socket.on('close', () => {
        console.log('❌ Client disconnected');
    });
});

console.log('🚀 WebSocket server running on ws://localhost:3002');
