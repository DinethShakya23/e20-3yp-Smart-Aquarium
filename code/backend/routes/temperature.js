const express = require('express');
const router = express.Router();
const TemperatureController = require('../controllers/temperatureController');

// Route to get hourly-aggregated temperatures for a specific date
// Example: GET /api/temperature/hourly
router.get('/hourly', TemperatureController.getHourlyTemperatureForAllDates);

module.exports = router;
