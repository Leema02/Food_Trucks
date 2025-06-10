const User = require("../models/userModel");
const generateToken = require("../utils/generateToken");
const jwt = require("jsonwebtoken");
const sendEmail = require("../utils/sendEmail");
const crypto = require("crypto");
const bcrypt = require("bcrypt");

const signupUser = async (req, res) => {
  const {
    F_name,
    L_name,
    email_address,
    phone_num,
    username,
    password,
    role_id,
    city,
    address,
  } = req.body;

  try {
    const existingUser = await User.findOne({ email_address });
    if (existingUser) {
      return res.status(409).json({ message: "Email already exists." });
    }
    const token = jwt.sign(
      {
        F_name,
        L_name,
        email_address,
        phone_num,
        username,
        password,
        role_id,
        city,
        address,
      },
      process.env.JWT_SECRET,
      { expiresIn: "10m" }
    );

    const verifyUrl = `${process.env.API_URL}/api/users/verify-email?token=${token}`;
    //const verifyUrl = `${process.env.CLIENT_URL}/verify-email?token=${token}`;

    const message = `
      <h2>Hello ${F_name},</h2>
      <p>Click below to verify your email and complete your signup:</p>
      <a href="${verifyUrl}" target="_blank">Verify Email</a>
      <p>This link expires in 10 minutes.</p>
    `;

    await sendEmail(email_address, "Verify your email - Food Trucks", message);

    res.status(200).json({
      message: "Verification email sent. Please check your inbox.",
    });
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
};

const getAllUsers = async (req, res) => {
  try {
    const users = await User.find().select("-password -__v");
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
        token: generateToken(user._id),
      });
    } else {
      res.status(401).json({ message: "Invalid email or password" });
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

    const existingUser = await User.findOne({
      email_address: decoded.email_address,
    });
    if (existingUser) {
      return res.status(400).send("❌ Account already verified.");
    }

    const newUser = await User.create({
      F_name: decoded.F_name,
      L_name: decoded.L_name,
      email_address: decoded.email_address,
      phone_num: decoded.phone_num,
      username: decoded.username,
      password: decoded.password,
      role_id: decoded.role_id,
      city: decoded.city,
      address: decoded.address,
    });

    res.status(201).json({ message: "✅ Email verified and account created." });
  } catch (err) {
    res.status(400).send("❌ Invalid or expired token.");
  }
};

const forgotPassword = async (req, res) => {
  const { email_address } = req.body;

  try {
    const user = await User.findOne({ email_address });
    if (!user) {
      return res.status(404).json({ message: "Email not found" });
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

    await sendEmail(
      user.email_address,
      "Your Password Reset Code - Food Trucks",
      message
    );

    res.status(200).json({ message: "Reset code sent to your email." });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

const verifyResetCode = async (req, res) => {
  const { email_address, code } = req.body;

  try {
    const user = await User.findOne({ email_address });

    if (!user || !user.resetCode || !user.resetCodeExpires) {
      return res.status(400).json({ message: "Invalid or expired code." });
    }

    if (user.resetCode !== code) {
      return res.status(400).json({ message: "Incorrect reset code." });
    }

    if (Date.now() > user.resetCodeExpires) {
      return res.status(400).json({ message: "Reset code has expired." });
    }

    return res.status(200).json({ message: "Code verified successfully." });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

const resetPassword = async (req, res) => {
  const { email_address, password } = req.body;

  try {
    const user = await User.findOne({ email_address });

    if (!user || !user.resetCode || !user.resetCodeExpires) {
      return res.status(400).json({ message: "No active reset request." });
    }

    if (Date.now() > user.resetCodeExpires) {
      return res.status(400).json({ message: "Reset code has expired." });
    }

    user.password = password;

    // Clear reset fields
    user.resetCode = undefined;
    user.resetCodeExpires = undefined;

    await user.save();

    res
      .status(200)
      .json({ message: "✅ Password has been reset successfully." });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};
const updateUser = async (req, res) => {
  const { id } = req.params;
  const {
    F_name,
    L_name,
    email_address,
    phone_num,
    username,
    password,
    role_id,
    city,
    address,
  } = req.body;

  try {
    const user = await User.findById(id);
    if (!user) return res.status(404).json({ message: "User not found" });

    // Optional fields — update only if provided
    if (F_name) user.F_name = F_name;
    if (L_name) user.L_name = L_name;
    if (email_address) user.email_address = email_address;
    if (phone_num) user.phone_num = phone_num;
    if (username) user.username = username;
    if (role_id) user.role_id = role_id;
    if (city) user.city = city;
    if (address) user.address = address;

    // If new password provided, hash it
    if (password) {
      const salt = await bcrypt.genSalt(10);
      user.password = await bcrypt.hash(password, salt);
    }

    const updatedUser = await user.save();
    res.status(200).json({
      message: "✅ User updated successfully",
      user: updatedUser,
    });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};
const deleteUser = async (req, res) => {
  const { id } = req.params;

  try {
    const user = await User.findByIdAndDelete(id);
    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    res.status(200).json({ message: "🗑️ User deleted successfully" });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};
const getTotalUsers = async (req, res) => {
  try {
    const totalUsers = await User.countDocuments();
    res.status(200).json({ totalUsers });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};
// 📈 New Users Over Time
const getUserSignupStats = async (req, res) => {
  try {
    const data = await User.aggregate([
      {
        $group: {
          _id: { $dateToString: { format: "%Y-%m", date: "$createdAt" } },
          count: { $sum: 1 },
        },
      },
      { $sort: { _id: 1 } },
    ]);

    res.status(200).json(data);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

const getAllUsersWithSearch = async (req, res) => {
  try {
    const { search } = req.query;

    const query = {};

    if (search) {
      query.$or = [
        { F_name: { $regex: search, $options: "i" } },
        { L_name: { $regex: search, $options: "i" } },
        { email_address: { $regex: search, $options: "i" } },
        { city: { $regex: search, $options: "i" } },
      ];
    }

    const users = await User.find(query).select("-password -__v");
    res.json(users);
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
  verifyResetCode,
  updateUser,
  deleteUser,
  getTotalUsers,
  getUserSignupStats,
  getAllUsersWithSearch
};
