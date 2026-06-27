// ═══════════════════════════════════════════════════════════════════════════
// MIDDLEWARE: Role-Based Access Control
// ═══════════════════════════════════════════════════════════════════════════

const requireRole = (roles) => (req, res, next) => {
  if (!req.user) return res.status(401).json({ success: false, message: 'Not authenticated' });
  if (!roles.includes(req.user.role)) {
    return res.status(403).json({ 
      success: false, 
      message: `Access denied. Required roles: ${roles.join(', ')}` 
    });
  }
  next();
};

const isOwner = (req, res, next) => {
  if (!req.user || !['owner', 'super_admin'].includes(req.user.role)) {
    return res.status(403).json({ success: false, message: 'Owner access required' });
  }
  next();
};

const isAdmin = (req, res, next) => {
  if (!req.user || !['owner', 'super_admin', 'admin'].includes(req.user.role)) {
    return res.status(403).json({ success: false, message: 'Admin access required' });
  }
  next();
};

module.exports = { requireRole, isOwner, isAdmin };
