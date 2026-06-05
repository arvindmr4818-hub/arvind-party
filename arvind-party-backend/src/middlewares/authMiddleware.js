const jwt = require('jsonwebtoken');

module.exports = (req, res, next) => {
  try {
    let token = req.headers.authorization;

    if (!token) {
      return res.status(401).json({ message: "Unauthorized" });
    }

    if (token.startsWith('Bearer ')) {
      token = token.split(' ')[1];
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET || 'arvind_party_secret_key');
    req.user = decoded;

    next();
  } catch (error) {
    return res.status(401).json({ message: "Invalid Token" });
  }
};
