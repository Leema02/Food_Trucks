const User = require('../models/userModel');
const generateToken = require('../utils/generateToken');
const jwt = require('jsonwebtoken');
const sendEmail = require('../utils/sendEmail');
const crypto = require('crypto'); 
const bcrypt = require('bcrypt');

const signupUser = async (req, res) => {
  const { F_name, L_name, email_address, phone_num, username, password, role_id, city, address } = req.body;

  try {
    const existingUser = await User.findOne({ email_address });
    if (existingUser) {
      return res.status(409).json({ message: 'Email already exists.' });
    }
    const token = jwt.sign(
      { F_name, L_name, email_address, phone_num, username, password, role_id, city, address },
      process.env.JWT_SECRET,
      { expiresIn: '10m' }
    );

    const verifyUrl = `${process.env.API_URL}/api/users/verify-email?token=${token}`;
    //const verifyUrl = `${process.env.CLIENT_URL}/verify-email?token=${token}`;

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


const getAllUsers = async (req, res) => {
    try {
      const users = await User.find().select('-password -__v'); // exclude sensitive fields
      res.json(users);
    } catch (err) {
      res.status(500).json({ message: err.message });
    }
  };


 

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

 //   const hashedPassword = await bcrypt.hash(decoded.password, 10);
    const newUser = await User.create({
      F_name: decoded.F_name,
      L_name: decoded.L_name,
      email_address: decoded.email_address,
      phone_num: decoded.phone_num,
      username: decoded.username,
      password: decoded.password,
      role_id: decoded.role_id,
      city: decoded.city,
      address: decoded.address
    });

    // const finalToken = generateToken(newUser._id);

    // res.status(201).json({
    //   message: '✅ Email verified and account created.',
    //   user: newUser,
    //   token: finalToken
    // });
    res.status(201).json({ message: '✅ Email verified and account created.' });

  } catch (err) {
    res.status(400).send('❌ Invalid or expired token.');
  }
};

const forgotPassword = async (req, res) => {
  const { email_address } = req.body;

  try {
    const user = await User.findOne({ email_address });
    if (!user) {
      return res.status(404).json({ message: 'Email not found' });
    }

    // Generate 4-digit numeric code
    const resetCode = Math.floor(1000 + Math.random() * 9000).toString();

    // Set expiry time (10 mins)
    const codeExpiry = Date.now() + 10 * 60 * 1000;

    user.resetCode = resetCode;
    user.resetCodeExpires = codeExpiry;
    await user.save();

    const message = `
      <h2>Hello ${user.F_name},</h2>
      <p>Use this 4-digit code to reset your password:</p>
      <h1>${resetCode}</h1>
      <p>This code will expire in 10 minutes.</p>
    `;

    await sendEmail(user.email_address, 'Your Password Reset Code - Food Trucks', message);

    res.status(200).json({ message: 'Reset code sent to your email.' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};
  
// const forgotPassword = async (req, res) => {
//   const { email_address } = req.body;

//   try {
//     // 1. Find user by email
//     const user = await User.findOne({ email_address });
//     if (!user) {
//       return res.status(404).json({ message: 'Email not found' });
//     }

//     // 2. Create a reset token
//     const resetToken = crypto.randomBytes(32).toString('hex');
//     const hashedToken = crypto.createHash('sha256').update(resetToken).digest('hex');

//     // 3. Save hashed token and expiration in DB
//     user.resetPasswordToken = hashedToken;
//     user.resetPasswordExpires = Date.now() + 10 * 60 * 1000; // 10 minutes
//     await user.save();

//     // 4. Send reset link by email
//     //const resetURL = `${process.env.CLIENT_URL}/reset-password/${resetToken}`;
//     const resetURL = `${process.env.API_URL}/api/users/reset-password/${resetToken}`;


//     const message = `
//       <h2>Hello ${user.F_name},</h2>
//       <p>Click below to reset your password:</p>
//       <a href="${resetURL}" target="_blank">Reset Password</a>
//       <p>This link will expire in 10 minutes.</p>
//     `;

//     await sendEmail(user.email_address, 'Reset your password - Food Trucks', message);

//     res.status(200).json({ message: 'Reset link sent to email' });

//   } catch (err) {
//     res.status(500).json({ message: err.message });
//   }
// };

const verifyResetCode = async (req, res) => {
  const { email_address, code } = req.body;

  try {
    const user = await User.findOne({ email_address });

    if (!user || !user.resetCode || !user.resetCodeExpires) {
      return res.status(400).json({ message: 'Invalid or expired code.' });
    }

    if (user.resetCode !== code) {
      return res.status(400).json({ message: 'Incorrect reset code.' });
    }

    if (Date.now() > user.resetCodeExpires) {
      return res.status(400).json({ message: 'Reset code has expired.' });
    }

    return res.status(200).json({ message: 'Code verified successfully.' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};


const resetPassword = async (req, res) => {
  const { email_address, password } = req.body;

  try {
    const user = await User.findOne({ email_address });

    if (!user || !user.resetCode || !user.resetCodeExpires) {
      return res.status(400).json({ message: 'No active reset request.' });
    }

    if (Date.now() > user.resetCodeExpires) {
      return res.status(400).json({ message: 'Reset code has expired.' });
    }

    // Hash and update the new password
    const hashedPassword = await bcrypt.hash(password, 10);
    user.password = hashedPassword;

    // Clear reset fields
    user.resetCode = undefined;
    user.resetCodeExpires = undefined;

    await user.save();

    res.status(200).json({ message: '✅ Password has been reset successfully.' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

  module.exports = {
    signupUser,
    getAllUsers,
    loginUser,
    verifyEmail,
    forgotPassword,
    resetPassword,
    verifyResetCode
  };
  