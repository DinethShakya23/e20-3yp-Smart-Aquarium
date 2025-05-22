const { Sequelize, TurbidityReading } = require('../models');

const TurbidityController = {
    // GET /api/turbidity/hourly
    async getHourlyTurbidityForAllDates(req, res) {
        try {
            const rows = await TurbidityReading.findAll({
                attributes: [
                    'date',
                    [Sequelize.fn('SUBSTRING', Sequelize.col('time'), 1, 2), 'hour'],
                    [Sequelize.fn('AVG', Sequelize.col('turbidity')), 'avgTurbidity']
                ],
                group: ['date', Sequelize.literal('hour')],
                order: [['date', 'ASC'], [Sequelize.literal('hour'), 'ASC']]
            });

            const result = {};

            rows.forEach(row => {
                const date = row.get('date');
                const hour = row.get('hour');
                const avgTurbidity = parseFloat(row.get('avgTurbidity').toFixed(2));

                if (!result[date]) {
                    result[date] = [];
                }

                result[date].push({
                    time: `${hour}:00`,
                    turbidity: avgTurbidity
                });
            });

            res.json(result);
        } catch (err) {
            console.error('❌ Error fetching turbidity data:', err);
            res.status(500).json({ error: 'Internal server error' });
        }
    }
};

module.exports = TurbidityController;
