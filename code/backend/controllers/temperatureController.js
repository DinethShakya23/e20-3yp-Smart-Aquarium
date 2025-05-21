const { Sequelize, TemperatureReading } = require('../models');

const TemperatureController = {
  // GET /api/temperature/hourly
  async getHourlyTemperatureForAllDates(req, res) {
    try {
      const rows = await TemperatureReading.findAll({
        attributes: [
          'date',
          [Sequelize.fn('SUBSTRING', Sequelize.col('time'), 1, 2), 'hour'],
          [Sequelize.fn('AVG', Sequelize.col('temperature')), 'avgTemperature']
        ],
        group: ['date', Sequelize.literal('hour')],
        order: [['date', 'ASC'], [Sequelize.literal('hour'), 'ASC']]
      });

      const result = {};

      rows.forEach(row => {
        const date = row.get('date');
        const hour = row.get('hour');
        const avgTemp = parseFloat(row.get('avgTemperature').toFixed(1));

        if (!result[date]) {
          result[date] = [];
        }

        result[date].push({
          time: `${hour}:00`,
          temperature: avgTemp
        });
      });

      res.json(result);
    } catch (err) {
      console.error('❌ Error fetching temperature data:', err);
      res.status(500).json({ error: 'Internal server error' });
    }
  }
};

module.exports = TemperatureController;


