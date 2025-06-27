const axios = require("axios");
const db = require("../models"); // Sequelize models index

exports.requestWiFiChange = async (req, res) => {
    console.log("📥 Received request body:", req.body);

    const { ssid, password, pi_ip } = req.body;

    // Validate request data
    if (!ssid || !password || !pi_ip) {
        console.warn("⚠️ Missing required fields in request body");
        await db.WiFiLog.logWiFiChange(ssid || "UNKNOWN", false, "Missing required fields");
        return res.status(400).json({ error: "Missing required fields: ssid, password, and pi_ip are required." });
    }

    try {
        // Forward request to Raspberry Pi
        const response = await axios.post(`http://${pi_ip}:5000/api/change-wifi`, {
            ssid,
            password,
        });

        // Log successful attempt
        await db.WiFiLog.logWiFiChange(ssid, true, null);

        // Respond to frontend
        return res.status(200).json({
            message: "✅ Wi-Fi change forwarded to Raspberry Pi.",
            pi_response: response.data,
        });

    } catch (err) {
        // Log error
        const errorMessage = err.response?.data?.error || err.message || "Unknown error";
        console.error("❌ Error contacting Raspberry Pi:", errorMessage);

        await db.WiFiLog.logWiFiChange(ssid, false, errorMessage);

        return res.status(500).json({
            error: "❌ Failed to contact Raspberry Pi.",
            details: errorMessage,
        });
    }
};

