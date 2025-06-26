module.exports = (sequelize, DataTypes) => {
    // Define the model
    const WiFiLog = sequelize.define('WiFiLog', {
        id: {
            type: DataTypes.INTEGER,
            autoIncrement: true,
            primaryKey: true,
        },
        ssid: {
            type: DataTypes.STRING,
            allowNull: false,
        },
        success: {
            type: DataTypes.BOOLEAN,
            allowNull: false,
        },
        error: {
            type: DataTypes.STRING,
            allowNull: true,
        },
        timestamp: {
            type: DataTypes.DATE,
            allowNull: false,
            defaultValue: DataTypes.NOW,
        },
    }, {
        tableName: 'wifi_logs',
        timestamps: false,  // We have our own timestamp field
    });

    // Add helper function as a static method of the model
    WiFiLog.logWiFiChange = async function (ssid, success, errorMsg = '') {
        try {
            await this.create({
                ssid,
                success,
                error: errorMsg,
                timestamp: new Date(),
            });
        } catch (error) {
            console.error("Failed to log Wi-Fi change:", error);
        }
    };

    return WiFiLog;
};
