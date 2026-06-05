const jwt = require('jsonwebtoken');

exports.login = async (req, res) => {
  try {
    const { username, password } = req.body;

    // Simple admin check — production mein Admin model banana
    const adminUser = process.env.ADMIN_USERNAME || 'arvind_admin';
    const adminPass = process.env.ADMIN_PASSWORD || 'admin@arvind2025';

    if (username !== adminUser || password !== adminPass) {
      return res.status(401).json({ success: false, message: 'Invalid credentials' });
    }

    const token = jwt.sign(
      { id: 'admin', role: 'admin' },
      process.env.JWT_SECRET || 'arvind_party_secret',
      { expiresIn: '7d' }
    );

    return res.json({ success: true, token, role: 'admin' });
  } catch (e) {
    return res.status(500).json({ success: false, message: e.message });
  }
};
