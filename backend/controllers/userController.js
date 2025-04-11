const User = require('../models/userModel');
const generateToken = require('../utils/generateToken');
const jwt = require('jsonwebtoken');
const sendEmail = require('../utils/sendEmail');


const signupUser = async (req, res) => {
  const { F_name, L_name, email_address, phone_num, username, password, role_id } = req.body;

  try {
    const existingUser = await User.findOne({ email_address });
    if (existingUser) {
      return res.status(409).json({ message: 'Email already exists.' });
    }
    const token = jwt.sign(
             { F_name, L_name, email_address, phone_num, username, password, role_id },
        process.env.JWT_SECRET,
        { expiresIn: '10m' }
      );

    //const verifyUrl = `${process.env.CLIENT_URL}/verify-email?token=${token}`;
    const verifyUrl = `${process.env.API_URL}/api/users/verify-email?token=${token}`;


    const message = `
      <h2>Hello ${F_name},</h2>
      <p>Click below to verify your email and complete your signup:</p>
      <a href="${verifyUrl}" target="_blank">Verify Email</a>
      <p>This link expires in 10 minutes.</p>
    `;

    await sendEmail(email_address, 'Verify your email - Food Trucks', message);

    res.status(200).json({
      message: 'Verification email sent. Please check your inbox.'
    });
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
};

module.exports = { signupUser };




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

// ✅ GET /api/users/verify-email?token=...
const verifyEmail = async (req, res) => {
    const token = req.query.token;
  
    try {
      const decoded = jwt.verify(token, process.env.JWT_SECRET);
  
      const existingUser = await User.findOne({ email_address: decoded.email_address });
      if (existingUser) {
        return res.status(400).send('❌ Account already verified.');
      }
  
      const hashedPassword = await bcrypt.hash(decoded.password, 10);
  
      const newUser = await User.create({
        F_name: decoded.F_name,
        L_name: decoded.L_name,
        email_address: decoded.email_address,
        phone_num: decoded.phone_num,
        username: decoded.username,
        password: hashedPassword,
        role_id: decoded.role_id
      });
  
      const finalToken = generateToken(newUser._id);
  
      res.status(201).json({
        message: '✅ Email verified and account created.',
        user: newUser,
        token: finalToken
      });
    } catch (err) {
      res.status(400).send('❌ Invalid or expired token.');
    }
  };

  module.exports = {
    signupUser,
    getAllUsers,
    loginUser,
    verifyEmail
  };
  