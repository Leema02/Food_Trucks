
const authorizeRoles = (...allowedRoles) => {
    return (req, res, next) => {
      if (!req.user || !req.user.role_id) { //req.user Comes from your existing protect middleware (attached after decoding JWT)
        return res.status(401).json({ message: 'Not authorized' });
      }
  
      if (!allowedRoles.includes(req.user.role_id)) {
        return res.status(403).json({ message: 'Access denied: insufficient permissions' }); //User logged in but doesn't have permission
      }
  
      next();
    };
  };
  
  module.exports = { authorizeRoles };
  