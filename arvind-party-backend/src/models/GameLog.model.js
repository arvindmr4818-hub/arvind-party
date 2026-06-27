const mongoose = require('mongoose');
const gameLogSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  gameType: { type: String, required: true },
  betAmount: { type: Number, required: true },
  winAmount: { type: Number, default: 0 },
  result: { type: String, enum: ['win', 'lose', 'draw'], required: true },
  details: { type: mongoose.Schema.Types.Mixed },
}, { timestamps: true });
gameLogSchema.index({ userId: 1, createdAt: -1 });
module.exports = mongoose.model('GameLog', gameLogSchema);
