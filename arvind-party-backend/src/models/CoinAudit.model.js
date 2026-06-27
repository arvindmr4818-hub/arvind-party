const mongoose = require('mongoose');

const coinAuditSchema = new mongoose.Schema({
  adminId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  adminName: { type: String, required: true },
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  userName: { type: String },
  amount: { type: Number, required: true },
  type: { type: String, enum: ['coins', 'diamonds'], default: 'coins' },
  reason: { type: String, required: true },
  action: { type: String, enum: ['add', 'deduct', 'bulk'], default: 'add' },
}, { timestamps: true });

coinAuditSchema.index({ createdAt: -1 });
coinAuditSchema.index({ adminId: 1 });
coinAuditSchema.index({ userId: 1 });

module.exports = mongoose.model('CoinAudit', coinAuditSchema);
