const express = require("express");
const router = express.Router();

const wifiController = require("../controllers/wifiController");

router.post("/change-wifi", wifiController.requestWiFiChange);

module.exports = router;
