'use strict';

module.exports = (sequelize, DataTypes) => {
  const TemperatureReading = sequelize.define('TemperatureReading', {
    id: {
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
    temperature: {
      type: DataTypes.FLOAT,
      allowNull: false
    }
  }, {
    tableName: 'temperature_readings',
    timestamps: false
  });

  return TemperatureReading;
};
