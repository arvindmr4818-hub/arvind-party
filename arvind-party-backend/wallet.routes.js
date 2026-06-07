const express = require('express');
const router = express.Router();
const walletController = require('./wallet.controller');

// TODO: Add authMiddleware
router.get('/', walletController.getWallet);
router.post('/recharge', walletController.recharge);
router.post('/recharge/stripe/intent', walletController.createStripeIntent);
router.post('/recharge/razorpay/order', walletController.createRazorpayOrder);
router.get('/transactions', walletController.getTransactions);
router.get('/withdrawal-info', walletController.getWithdrawalInfo);
router.post('/seller/transfer', walletController.coinSellerTransfer);
router.post('/withdraw', walletController.withdraw);

module.exports = router;