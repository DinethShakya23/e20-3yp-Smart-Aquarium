const express = require('express');
const cors = require('cors');
const path = require('path');

const userRoutes = require('./routes/userRoutes');
const profileRoutes = require('./routes/profileRoutes');
// const authRoutes = require('./routes/auth');


const { sequelize } = require('./models'); // Sequelize instance

const app = express();

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Static file serving for profile image uploads
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// Routes
app.use('/api', userRoutes);
app.use('/api', profileRoutes);
// app.use('/api', authRoutes);

// Root route
app.get('/', (req, res) => {
    res.send('🚀 Backend server is running!');
});

// Test DB connection and sync
sequelize.authenticate()
    .then(() => {
        console.log('✅ Database connection has been established successfully.');
        return sequelize.sync(); // Creates tables if not exist
    })
    .then(() => {
        console.log('✅ Database synced');
    })
    .catch(err => {
        console.error('❌ Unable to connect to the database:', err);
    });

module.exports = app;

