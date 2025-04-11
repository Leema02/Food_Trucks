const express = require('express');
const router = express.Router();
const User = require('../models/userModel');

const UserController = require('../controllers/userController');

router.post('/signup', UserController.signupUser ); //sign up
router.get('/', UserController.getAllUsers ); // Get all users


module.exports = router;
