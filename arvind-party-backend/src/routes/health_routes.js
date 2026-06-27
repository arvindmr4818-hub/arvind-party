const express = require('express');
const router = express.Router();
const mongoose = require('mongoose');

router.get('/', async (req, res) => {
  const dbState = mongoose.connection.readyState;
  res.json({
    success: true, status: 'healthy',
    database: dbState === 1 ? 'connected' : 'disconnected',
    uptime: Math.floor(process.uptime()),
    memory: process.memoryUsage(),
    timestamp: new Date().toISOString(),
  });
});

module.exports = router;
