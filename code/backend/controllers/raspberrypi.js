
// TO see use(In CMD) = mosquitto_sub -h 192.168.3.244 -t sensor/ph

import { connect } from 'mqtt';
import { Server } from 'socket.io';
import http from 'http';

// MQTT Configuration
const MQTT_BROKER = '192.168.3.244'; // Your broker IP
const MQTT_PORT = 1883;
const MQTT_TOPIC = 'sensor/ph';

// WebSocket Server Setup
const server = http.createServer(); // Create an HTTP server
const io = new Server(server, {
    cors: { origin: '*' } // Allow any origin for testing
});

// Start MQTT Client
const mqttClient = connect(`mqtt://${MQTT_BROKER}:${MQTT_PORT}`);

mqttClient.on('connect', () => {
    console.log('✅ Connected to MQTT broker');
    mqttClient.subscribe(MQTT_TOPIC);
});

// Handle Incoming MQTT Messages
mqttClient.on('message', (topic, message) => {
    try {
        const data = JSON.parse(message.toString());
        console.log(`📡 Received pH Data: Voltage=${data.voltage}V | pH=${data.pH}`);

        // Broadcast the data to all WebSocket clients
        io.emit('sensorData', data);
    } catch (error) {
        console.error('❌ Error parsing message:', error);
    }
});

// Handle WebSocket Connections
io.on('connection', (socket) => {
    console.log('🔗 Client connected to WebSocket');
    
    socket.on('disconnect', () => {
        console.log('❌ Client disconnected');
    });
});

// Start WebSocket Server
const PORT = 3000;
server.listen(PORT, () => {
    console.log(`🚀 WebSocket server running on ws://localhost:${PORT}`);
});
