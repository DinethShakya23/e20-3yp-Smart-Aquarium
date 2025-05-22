const { Sequelize, PHReading } = require('../models');

const PHController = {
    // GET /api/ph/hourly
    async getHourlyPHForAllDates(req, res) {
        try {
            const rows = await PHReading.findAll({
                attributes: [
                    'date',
                    [Sequelize.fn('SUBSTRING', Sequelize.col('time'), 1, 2), 'hour'],
                    [Sequelize.fn('AVG', Sequelize.col('ph')), 'avgPH']
                ],
                group: ['date', Sequelize.literal('hour')],
                order: [['date', 'ASC'], [Sequelize.literal('hour'), 'ASC']]
            });

            const result = {};

            rows.forEach(row => {
                const date = row.get('date');
                const hour = row.get('hour');
                const avgPH = parseFloat(row.get('avgPH').toFixed(2));

                if (!result[date]) {
                    result[date] = [];
                }

                result[date].push({
                    time: `${hour}:00`,
                    ph: avgPH
                });
            });

            res.json(result);
        } catch (err) {
            console.error('❌ Error fetching pH data:', err);
            res.status(500).json({ error: 'Internal server error' });
        }
    }
};

module.exports = PHController;
