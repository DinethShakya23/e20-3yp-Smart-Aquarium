const axios = require("axios");
const db = require("../models");  // This should be your Sequelize models index

exports.requestWiFiChange = async (req, res) => {
    const { ssid, password, pi_ip } = req.body;

    if (!ssid || !password || !pi_ip) {
        // Await if you want to ensure logging completes before returning
        await db.WiFiLog.logWiFiChange(ssid || "UNKNOWN", false, "Missing required fields");
        return res.status(400).json({ error: "Missing required fields." });
    }

    try {
        const response = await axios.post(`http://${pi_ip}:3001/api/change-wifi`, {
            ssid,
            password,
        });

        await db.WiFiLog.logWiFiChange(ssid, true);

        return res.status(200).json({
            message: "Wi-Fi change forwarded to Raspberry Pi.",
            pi_response: response.data,
        });
    } catch (err) {
        await db.WiFiLog.logWiFiChange(ssid, false, err.message);

        return res.status(500).json({
            error: "Failed to contact Raspberry Pi.",
            details: err.message,
        });
    }
};

