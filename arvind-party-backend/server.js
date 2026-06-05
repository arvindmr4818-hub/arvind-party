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

connectDB();

const app = express();
const server = http.createServer(app);
const io = initializeSocket(server);

// Middleware
app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));
app.use(express.json({ limit: '10mb' }));

// Routes
app.use('/api/auth', require('./src/routes/authRoutes'));
app.use('/api/rooms', require('./src/routes/roomRoutes'));
app.use('/api/users', require('./src/routes/userRoutes'));
app.use('/api/wallet', require('./src/routes/walletRoutes'));
app.use('/api/gifts', require('./src/routes/giftRoutes'));
app.use('/api/family', require('./src/routes/familyRoutes'));
app.use('/api/agency', require('./src/routes/agencyRoutes'));
app.use('/api/rankings', require('./src/routes/rankingRoutes'));

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

const PORT = process.env.PORT || 5000;
server.listen(PORT, () => {
  console.log(`✅ Server running on port ${PORT}`);
  console.log(`📡 Socket.io ready`);
  console.log(`🌐 http://localhost:${PORT}`);
});
