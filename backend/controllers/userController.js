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
  
  module.exports = {
    signupUser,
    getAllUsers
  };
  