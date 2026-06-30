// ═══════════════════════════════════════════════════════════════════════════
// MODULE: wallet/paymentRoutes.js — Razorpay Payment Integration
// ═══════════════════════════════════════════════════════════════════════════

const express = require('express');
const router = express.Router();
const crypto = require('crypto');
const Razorpay = require('razorpay');
const { protect } = require('../../middlewares/auth.middleware');
const User = require('../../models/User');
const Transaction = require('../../models/Transaction');

const getRazorpay = () => {
  if (!process.env.RAZORPAY_KEY_ID || !process.env.RAZORPAY_KEY_SECRET) return null;
  return new Razorpay({
    key_id: process.env.RAZORPAY_KEY_ID,
    key_secret: process.env.RAZORPAY_KEY_SECRET,
  });
};

// POST /api/wallet/create-order
router.post('/create-order', protect, async (req, res) => {
  try {
    const { amount, coins } = req.body;
    if (!amount || !coins) return res.status(400).json({ success: false, message: 'amount and coins required' });

    const razorpay = getRazorpay();
    if (!razorpay) return res.status(503).json({ success: false, message: 'Payment gateway not configured. Add RAZORPAY_KEY_ID and RAZORPAY_KEY_SECRET to .env' });

    const order = await razorpay.orders.create({
      amount: amount * 100, // paise
      currency: 'INR',
      receipt: `rcpt_${req.user._id}_${Date.now()}`,
      notes: { userId: req.user._id.toString(), coins: String(coins) },
    });

    // Store pending transaction
    await Transaction.create({
      userId: req.user._id,
      type: 'recharge',
      amount,
      coins,
      status: 'pending',
      razorpayOrderId: order.id,
    });

    res.json({
      success: true,
      data: { orderId: order.id, amount: order.amount, keyId: process.env.RAZORPAY_KEY_ID },
    });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

// POST /api/wallet/verify-payment
router.post('/verify-payment', protect, async (req, res) => {
  try {
    const { razorpay_payment_id, razorpay_order_id, razorpay_signature } = req.body;
    if (!razorpay_payment_id || !razorpay_order_id || !razorpay_signature) {
      return res.status(400).json({ success: false, message: 'Missing payment details' });
    }

    // Verify signature
    const generatedSignature = crypto
      .createHmac('sha256', process.env.RAZORPAY_KEY_SECRET)
      .update(`${razorpay_order_id}|${razorpay_payment_id}`)
      .digest('hex');

    if (generatedSignature !== razorpay_signature) {
      return res.status(400).json({ success: false, message: 'Invalid payment signature' });
    }

    // Find pending transaction
    const txn = await Transaction.findOne({ razorpayOrderId: razorpay_order_id, status: 'pending' });
    if (!txn) return res.status(404).json({ success: false, message: 'Transaction not found' });

    // Credit coins
    const user = await User.findById(txn.userId);
    user.coins = (user.coins || 0) + txn.coins;
    await user.save();

    txn.status = 'completed';
    txn.razorpayPaymentId = razorpay_payment_id;
    txn.completedAt = new Date();
    await txn.save();

    res.json({ success: true, message: 'Payment verified', data: { coins: user.coins } });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

// GET /api/wallet/balance
router.get('/balance', protect, async (req, res) => {
  try {
    const user = await User.findById(req.user._id).select('coins diamonds');
    res.json({ success: true, data: { coins: user.coins || 0, diamonds: user.diamonds || 0 } });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

// GET /api/wallet/transactions
router.get('/transactions', protect, async (req, res) => {
  try {
    const txns = await Transaction.find({ userId: req.user._id })
      .sort({ createdAt: -1 }).limit(50).lean();
    const mapped = txns.map(t => ({
      ...t,
      description: t.type === 'recharge' ? `Recharged ${t.coins} coins`
        : t.type === 'gift' ? 'Sent a gift'
        : t.type === 'withdrawal' ? 'Withdrawal request'
        : t.type,
      amount: t.type === 'withdrawal' ? -(t.amount || 0) : (t.coins || t.amount || 0),
    }));
    res.json({ success: true, data: mapped });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

// POST /api/wallet/withdraw
router.post('/withdraw', protect, async (req, res) => {
  try {
    const { amount } = req.body;
    if (!amount || amount < 500) return res.status(400).json({ success: false, message: 'Minimum withdrawal is 500 diamonds' });

    const user = await User.findById(req.user._id);
    if ((user.diamonds || 0) < amount) {
      return res.status(400).json({ success: false, message: 'Insufficient diamonds' });
    }

    user.diamonds -= amount;
    await user.save();

    await Transaction.create({
      userId: req.user._id,
      type: 'withdrawal',
      amount,
      status: 'pending',
    });

    res.json({ success: true, message: 'Withdrawal request submitted', data: { diamonds: user.diamonds } });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

module.exports = router;
