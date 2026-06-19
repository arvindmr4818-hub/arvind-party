// ═══════════════════════════════════════════════════════════════════════════
// FILE: src/config/cors.js
// ARVIND PARTY - CORS CONFIGURATION
// Restrict origins in production for security
// ═══════════════════════════════════════════════════════════════════════════

const cors = require('cors');

// Allowed origins based on environment
const allowedOrigins = (() => {
  if (process.env.NODE_ENV === 'production') {
    return [
      'https://api.arvindparty.com',
      'https://admin.arvindparty.com',
      'https://arvindparty.com',
    ];
  }
  // Development: allow all common origins for testing
  return [
    'http://localhost:3000',
    'http://localhost:5000',
    'http://localhost:8080',
    'http://localhost:52779',
    'http://127.0.0.1:3000',
    'http://127.0.0.1:5000',
    'http://192.168.1.100:5000',
    'http://192.168.1.100:52779',
  ];
})();

const corsConfig = cors({
  origin: function (origin, callback) {
    // Allow requests with no origin (mobile apps, curl, etc.)
    if (!origin || process.env.NODE_ENV !== 'production') return callback(null, true);

    if (allowedOrigins.indexOf(origin) !== -1) {
      callback(null, true);
    } else {
      callback(new Error(`Origin ${origin} not allowed by CORS`));
    }
  },
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With', 'Accept'],
  exposedHeaders: ['Content-Range', 'X-Content-Range'],
  maxAge: 86400, // 24 hours
});

module.exports = corsConfig;