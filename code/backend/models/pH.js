'use strict';

module.exports = (sequelize, DataTypes) => {
    const PHReading = sequelize.define('PHReading', {
        pHid: {
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
        ph: {
            type: DataTypes.FLOAT,
            allowNull: false
        }
    }, {
        tableName: 'ph_readings',
        timestamps: false
    });

    return PHReading;
};
