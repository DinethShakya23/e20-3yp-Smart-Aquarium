const { User } = require('../models');
// Bcrypt for hashing passwords
const bcrypt = require('bcryptjs');

const UserController = {
    // Register a new user
    async createUser(req, res) {
        try {
            const { email, password } = req.body;

            // Check if user already exists
            const existingUser = await User.findOne({ where: { email } });
            if (existingUser) {
                return res.status(400).json({ error: 'User already exists' });
            }

            // Hash the password
            const hashedPassword = User.hashPassword(password);

            // Create a new user
            const user = await User.create({ email, password: hashedPassword });
            res.status(201).json({ message: 'User registered successfully', user });
        } catch (error) {
            res.status(500).json({ error: error.message });
        }
    },

    // Login an existing user
    async loginUser(req, res) {
        try {
            const { email, password } = req.body;

            // Find user by email
            const user = await User.findOne({ where: { email } });
            if (!user) {
                return res.status(400).json({ error: 'Invalid email or password' });
            }

            // Compare provided password with stored hashed password
            const isValidPassword = user.checkPassword(password);
            if (!isValidPassword) {
                return res.status(400).json({ error: 'Invalid password' });
            }

            
            
            // Send response with token
            res.json( 'Login successful');
        } catch (error) {
            res.status(500).json({ error: error.message });
        }
    },
};

module.exports = UserController;