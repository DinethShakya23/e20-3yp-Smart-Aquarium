const express = require('express');
const router = express.Router();
const multer = require('multer');
const path = require('path');
const { saveProfile, getProfile } = require('../controllers/profileController');
const { Profile } = require('../models/profile');

// Multer setup
const storage = multer.diskStorage({
    destination: function (_, __, cb) {
        cb(null, path.join(__dirname, '../uploads'));
    },
    filename: function (_, file, cb) {
        const uniqueName = `${Date.now()}${path.extname(file.originalname)}`;
        cb(null, uniqueName);
    },
});
const upload = multer({ storage });

// POST route to save profile
router.post('/profile', upload.single('image'), saveProfile);

// GET route to retrieve profile by email
router.get('/profile/:email', getProfile);

module.exports = router;

