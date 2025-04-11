const User = require('../models/userModel');
const generateToken = require('../utils/generateToken');


const signupUser = async (req, res) => {
    try {
      const newUser = await User.create(req.body);
  
      // Let Mongoose handle hiding password, __v, timestamps via toJSON in usermodel
      res.status(201).json({
        user: newUser,
        token: generateToken(newUser._id)
      });
    } catch (err) {
      if (err.code === 11000) {
        const field = Object.keys(err.keyPattern)[0];
        return res.status(409).json({ message: `${field} already exists.` });
      }
      res.status(400).json({ message: err.message });
    }
  };




const getAllUsers = async (req, res) => {
    try {
      const users = await User.find().select('-password -__v'); // exclude sensitive fields
      res.json(users);
    } catch (err) {
      res.status(500).json({ message: err.message });
    }
  };
  
  const bcrypt = require('bcrypt');

const loginUser = async (req, res) => {
  const { email_address, password } = req.body;

  try {
    // 1. Find user by email
    const user = await User.findOne({ email_address });

    // 2. Check if user exists and password matches
    if (user && (await bcrypt.compare(password, user.password))) {
      res.status(200).json({
        user, // 🧼 your schema handles hiding password in toJSON
        token: generateToken(user._id)
      });
    } else {
      res.status(401).json({ message: 'Invalid email or password' });
    }
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

  module.exports = {
    signupUser,
    getAllUsers,
    loginUser
  };
  