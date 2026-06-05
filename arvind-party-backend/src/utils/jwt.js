const jwt = require('jsonwebtoken');

const generateToken = (userId) => {
  return jwt.sign({ id: userId }, process.env.JWT_SECRET || 'arvind_party_secret_key', {
    expiresIn: '30d',
  });
};

module.exports = generateToken;
