const jwt = require('jsonwebtoken');
const User = require('../models/userModel');

const protect = async (req, res, next) => {
  let token;

  // Check for token in Authorization header
  if (
    req.headers.authorization &&
    req.headers.authorization.startsWith('Bearer')
  ) {
    try {
      // 1. Extract token from header
      token = req.headers.authorization.split(' ')[1];

      // 2. Verify token using secret key
      const decoded = jwt.verify(token, process.env.JWT_SECRET);

      // 3. Get user from DB (no password)
      const user = await User.findById(decoded.id).select('-password');

      if (!user) {
        return res.status(401).json({ message: 'User not found' });
      }

      // 4. Attach user to request
      req.user = user;

      next(); // ✅ All good, move to next middleware/route
    } catch (err) {
      console.error('JWT error:', err);
      return res.status(401).json({ message: 'Invalid token' });
    }
  } else {
    return res.status(401).json({ message: 'No token provided' });
  }
};

module.exports = { protect };
