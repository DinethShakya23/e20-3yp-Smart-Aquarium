const express = require('express');
const router = express.Router();
const PHController = require('../controllers/pHController');

router.get('/hourly-ph', PHController.getHourlyPHForAllDates);

module.exports = router;