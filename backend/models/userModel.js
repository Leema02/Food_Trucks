const mongoose = require("mongoose");
const bcrypt = require("bcrypt");

const userSchema = new mongoose.Schema(
  {
    F_name: { type: String, required: true },
    L_name: { type: String, required: true },
    email_address: { type: String, required: true, unique: true },
    phone_num: { type: String, required: true },
    username: { type: String, required: true, unique: true },
    password: { type: String, required: true },
    city: { type: String },
    address: { type: String },
    role_id: {
      type: String,
      enum: ["customer", "truck owner", "admin"],
      default: "customer",
    },
    resetCode: { type: String },
    resetCodeExpires: { type: Date },
  },
  {
    timestamps: true,
    toJSON: {
      transform: function (doc, ret) {
        delete ret.password;
        delete ret.__v;
        delete ret.updatedAt;
        return ret;
      },
    },
  }
);

// 🔐 Hash the password before saving
userSchema.pre("save", async function (next) {
  if (!this.isModified("password")) return next(); // Only hash if it's new or modified
  try {
    const salt = await bcrypt.genSalt(10);
    this.password = await bcrypt.hash(this.password, salt);
    next();
  } catch (err) {
    next(err);
  }
});

const User = mongoose.model("User", userSchema);

module.exports = User;
