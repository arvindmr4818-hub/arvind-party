const express = require('express');
const http = require('http');
const { Server } = require('socket.io');
const mongoose = require('mongoose');
const cors = require('cors');
const authRoutes = require('./routes/authRoutes');
require('dotenv').config();

const app = express();
const server = http.createServer(app);

// Socket.io Setup for Real-time features (Chat, PK, Gifts, Live Rooms)
const io = new Server(server, {
  cors: {
    origin: '*', // For development. Allow all origins.
    methods: ['GET', 'POST']
  }
});

// Middleware
app.use(cors());
app.use(express.json());

// API Routes
app.use('/api/auth', authRoutes);

// Basic Test API
app.get('/', (req, res) => {
  res.send('Arvind Party Backend is Running! 🚀');
});

// Database Connection
mongoose.connect(process.env.MONGO_URI)
  .then(() => {
    console.log('✅ MongoDB Connected Successfully');
  })
  .catch((err) => {
    console.error('❌ MongoDB Connection Error:', err);
  });

// Socket.io Connection Logic
io.on('connection', (socket) => {
  console.log(`⚡ New User connected: ${socket.id}`);

  socket.on('disconnect', () => {
    console.log(`🔴 User disconnected: ${socket.id}`);
  });
});

const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
  console.log(`🚀 Server running on http://localhost:${PORT}`);
});
