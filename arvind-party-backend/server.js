require('dotenv').config();
const express = require('express');
const http = require('http');
const cors = require('cors');
const connectDB = require('./src/config/db');
const { initializeSocket } = require('./src/config/socket');
const roomSocket = require('./src/sockets/roomSocket');
const chatSocket = require('./src/sockets/chatSocket');
const seatSocket = require('./src/sockets/seatSocket');
const giftSocket = require('./src/sockets/giftSocket');
const pkBattleSocket = require('./src/sockets/pkBattleSocket');

// Try to connect to MongoDB, but don't crash if it's not available
try {
  connectDB();
} catch (error) {
  console.log('⚠️ MongoDB not available, using fallback data');
}

// Initialize badges (async, don't block server startup)
const badgeController = require('./src/controllers/badgeController');
setTimeout(() => {
  badgeController.initializeDefaultBadges().catch(err => {
    console.log('⚠️ Badge initialization skipped:', err.message);
  });
}, 1000);

const app = express();
const server = http.createServer(app);
const io = initializeSocket(server);

// Make `io` accessible globally inside controllers
app.set('io', io);

// Middleware
app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));
app.use(express.json({ limit: '10mb' }));

// Routes
app.use('/api/auth', require('./src/routes/auth.routes'));
app.use('/api/rooms', require('./src/routes/room.routes'));
app.use('/api/users', require('./src/routes/user.routes'));
app.use('/api/wallet', require('./src/routes/walletRoutes'));
app.use('/api/gifts', require('./src/routes/gift.routes'));
app.use('/api/family', require('./src/routes/familyRoutes'));
app.use('/api/agency', require('./src/routes/agencyRoutes'));
app.use('/api/rankings', require('./src/routes/rankingRoutes'));
app.use('/api/shop', require('./src/routes/shopRoutes'));

// Admin Panel Routes (web panel ke liye)
app.use('/api/admin', require('./src/routes/adminRoutes'));

app.get('/', (req, res) => {
  res.json({ status: 'ok', message: 'ARVIND PARTY API running 🎉' });
});

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'ok', uptime: process.uptime() });
});

// Setup Socket Handlers
roomSocket(io);
chatSocket(io);
seatSocket(io);
giftSocket(io);
pkBattleSocket(io);

const PORT = process.env.PORT || 5000;
server.listen(PORT, () => {
  console.log(`✅ Server running on port ${PORT}`);
  console.log(`📡 Socket.io ready`);
  console.log(`🌐 http://localhost:${PORT}`);
});
