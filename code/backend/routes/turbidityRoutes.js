const express = require('express');
const router = express.Router();
const TurbidityController = require('../controllers/turbidityController');

router.get('/hourly-turbidity', TurbidityController.getHourlyTurbidityForAllDates);

module.exports = router;