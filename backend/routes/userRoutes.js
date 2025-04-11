const express = require('express');
const router = express.Router();
const User = require('../models/userModel');

router.post('/add', async (req, res) => {
  console.log("Request body:", req.body); 
  try {
    const newUser = await User.create(req.body);
    res.status(201).json(newUser);
  } catch (err) {
    if (err.code === 11000) {
      // Duplicate key error (unique violation)
      const field = Object.keys(err.keyPattern)[0];
      return res.status(409).json({ message: `${field} already exists.` });
    }
    res.status(400).json({ message: err.message });
  }
});


// Optional: Get all users
router.get('/', async (req, res) => {
  try {
    const users = await User.find();
    res.json(users);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;
