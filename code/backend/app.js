const express = require('express');
const cors = require('cors');
const userRoutes = require('./routes/userRoutes');
const app = express();

// Middleware to enable Cross-Origin Resource Sharing (CORS) for your API.
app.use(cors());
app.use(express.json());
app.use('/api', userRoutes);

// Test route
app.get('/', (req, res) => {
    res.send('Backend server is running!');
});

module.exports = app;