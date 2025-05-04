const path = require('path');
const fs = require('fs');
const { Profile } = require('../models');

// Ensure the uploads directory exists
const uploadDir = path.join(__dirname, '../uploads');
if (!fs.existsSync(uploadDir)) fs.mkdirSync(uploadDir);

// Save or update a profile
const saveProfile = async (req, res) => {
    const { name, email, phone, location } = req.body;
    const imageUrl = req.file ? req.file.filename : null;

    if (!name || !email || !phone || !location) {
        return res.status(400).json({ message: 'Missing required fields' });
    }

    try {
        const profile = await Profile.findOne({ where: { email } });

        if (profile) {
            // Update existing profile
            await profile.update({
                name,
                phone,
                location,
                ...(imageUrl && { image_url: imageUrl })
            });
        } else {
            // Create new profile
            await Profile.create({
                email,
                name,
                phone,
                location,
                image_url: imageUrl
            });
        }

        return res.status(200).json({ message: 'Profile saved', imageUrl });
    } catch (err) {
        console.error('Error saving profile:', err);
        return res.status(500).json({ message: 'Internal server error' });
    }
};

// Retrieve profile by email
const getProfile = async (req, res) => {
    const { email } = req.params;

    if (!email) {
        return res.status(400).json({ message: 'Email is required' });
    }

    try {
        const profile = await Profile.findByPk(email);
        if (!profile) {
            return res.status(404).json({ message: 'Profile not found' });
        }

        return res.status(200).json(profile);
    } catch (err) {
        console.error('Error fetching profile:', err);
        return res.status(500).json({ message: 'Internal server error' });
    }
};

module.exports = {
    saveProfile,
    getProfile,
};
