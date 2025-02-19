import { connect } from 'mqtt';

const MQTT_BROKER = 'your_mqtt_broker_ip';
const MQTT_PORT = 1883;
const MQTT_TOPIC = 'sensor/ph';

const client = connect(`mqtt://${MQTT_BROKER}:${MQTT_PORT}`);

client.on('connect', () => {
    console.log('Connected to MQTT broker');
    client.subscribe(MQTT_TOPIC);
});

client.on('message', (topic, message) => {
    console.log(`Received: ${message.toString()} from topic: ${topic}`);
});
