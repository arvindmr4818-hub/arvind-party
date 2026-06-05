// src/middlewares/adminMiddleware.js
// Web Panel se aane wale admin requests verify karta hai
// Admin token alag se generate hota hai ya special role hota hai

const ADMIN_SECRET = process.env.ADMIN_SECRET || 'arvind_admin_2024';

module.exports = (req, res, next) => {
  const adminKey = req.headers['x-admin-key'];
  
  // Option 1: Special admin key header
  if (adminKey && adminKey === ADMIN_SECRET) {
    req.isAdmin = true;
    return next();
  }
  
  // Option 2: JWT mein admin role (future use)
  if (req.user && req.user.role === 'admin') {
    req.isAdmin = true;
    return next();
  }

  return res.status(403).json({ 
    success: false, 
    message: 'Admin access required' 
  });
};
