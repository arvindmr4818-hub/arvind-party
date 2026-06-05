const User = require('../models/User');
const WalletTransaction = require('../models/WalletTransaction');

// GET /api/wallet
exports.getWallet = async (req, res) => {
  try {
    const user = await User.findById(req.user.id).select('coins diamonds userId name');
    const transactions = await WalletTransaction.find({ userId: req.user.id })
      .sort({ createdAt: -1 }).limit(20);
    return res.json({ success: true, coins: user.coins, diamonds: user.diamonds, transactions });
  } catch (e) {
    return res.status(500).json({ success: false, message: e.message });
  }
};

// POST /api/wallet/recharge (payment gateway baad mein lagega)
exports.recharge = async (req, res) => {
  try {
    const { amount, paymentRef } = req.body;
    if (!amount || amount <= 0)
      return res.status(400).json({ success: false, message: 'Invalid amount' });

    const user = await User.findById(req.user.id);
    user.coins += amount;
    await user.save();

    await WalletTransaction.create({
      userId: req.user.id,
      type: 'recharge',
      amount,
      description: `Recharged ${amount} coins`,
      ref: paymentRef || 'manual'
    });

    return res.json({ success: true, coins: user.coins, message: `${amount} coins added!` });
  } catch (e) {
    return res.status(500).json({ success: false, message: e.message });
  }
};

// GET /api/wallet/transactions
exports.getTransactions = async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = 20;
    const transactions = await WalletTransaction.find({ userId: req.user.id })
      .sort({ createdAt: -1 })
      .skip((page - 1) * limit)
      .limit(limit);
    return res.json({ success: true, transactions });
  } catch (e) {
    return res.status(500).json({ success: false, message: e.message });
  }
};
