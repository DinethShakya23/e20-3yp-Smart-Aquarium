'use strict';

module.exports = (sequelize, DataTypes) => {
    const TurbidityReading = sequelize.define('TurbidityReading', {
        turbidityid: {
            type: DataTypes.INTEGER,
            autoIncrement: true,
            primaryKey: true
        },
        date: {
            type: DataTypes.DATEONLY,
            allowNull: false
        },
        time: {
            type: DataTypes.STRING,
            allowNull: false
        },
        turbidity: {
            type: DataTypes.FLOAT,
            allowNull: false
        }
    }, {
        tableName: 'turbidity_readings',
        timestamps: false
    });

    return TurbidityReading;
};
