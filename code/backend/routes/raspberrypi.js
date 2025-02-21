import { connect } from 'mqtt';

const MQTT_BROKER = '192.168.3.244'; // your IP address
const MQTT_PORT = 1883;
const MQTT_TOPIC = 'sensor/ph';

const client = connect(`mqtt://${MQTT_BROKER}:${MQTT_PORT}`);

client.on('connect', () => {
    console.log('Connected to MQTT broker');
    client.subscribe(MQTT_TOPIC);
});

client.on('message', (topic, message) => {
    try {
        const data = JSON.parse(message.toString());
        console.log(`📡 Received pH Data: Voltage=${data.voltage}V | pH=${data.pH}`);
    } catch (error) {
        console.error('Error parsing message:', error);
    }
});
