// controllers/adminController.js
const User = require("../models/userModel");
const bcrypt = require("bcrypt");
const generateToken = require("../utils/generateToken");

const loginAdmin = async (req, res) => {
  const { email, password } = req.body;

  try {
    const admin = await User.findOne({
      email_address: email,
      role_id: "admin",
    });

    if (!admin || !(await bcrypt.compare(password, admin.password))) {
      return res
        .status(401)
        .json({ message: "البريد أو كلمة المرور غير صحيحة" });
    }

    res.status(200).json({
      message: "تم تسجيل الدخول بنجاح",
      token: generateToken(admin._id),
      admin: {
        id: admin._id,
        email: admin.email_address,
        name: `${admin.F_name} ${admin.L_name}`,
      },
    });
  } catch (err) {
    res.status(500).json({ message: "خطأ في الخادم", error: err.message });
  }
};

module.exports = { loginAdmin };
