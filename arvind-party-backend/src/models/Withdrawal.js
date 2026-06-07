const mongoose = require('mongoose');

const withdrawalSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  coinsDeducted: { type: Number, required: true },
  amountUSD: { type: Number, required: true },
  paymentDetails: { type: String, required: true }, // E.g. PayPal email or Bank details
  status: { type: String, enum: ['pending', 'approved', 'rejected', 'completed'], default: 'pending' },
  processedBy: { type: String, default: null } // To track which Admin/Owner approved it
}, { timestamps: true });

module.exports = mongoose.model('Withdrawal', withdrawalSchema);