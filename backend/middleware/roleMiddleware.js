// middleware/roleMiddleware.js

// Generic role-based authorization middleware
const authorizeRoles = (...allowedRoles) => {
  return (req, res, next) => {
    if (!req.user || !req.user.role_id) {
      return res
        .status(401)
        .json({ message: "Unauthorized: No user data found" });
    }

    if (!allowedRoles.includes(req.user.role_id)) {
      return res
        .status(403)
        .json({ message: "Access denied: insufficient permissions" });
        //User logged in but doesn't have permission
    }

    next();
  };
};

// Shortcut middleware just for admins
const authorizeAdmin = (req, res, next) => {
  if (!req.user || req.user.role_id !== "admin") {
    return res.status(403).json({ message: "Access denied: admins only" });
  }
  next();
};

module.exports = { authorizeRoles, authorizeAdmin };
