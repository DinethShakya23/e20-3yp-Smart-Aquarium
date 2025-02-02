const express = require('express');
const router = express.Router();
const UserController = require('../controllers/userController');

// Route to register a user
router.post('/register', UserController.createUser);

// Route to login a user
router.post('/login', UserController.loginUser);

module.exports = router;