const express = require('express');
const router = express.Router();
const auth = require('../middlewares/auth.middleware');
const ctrl = require('../controllers/walletController');

router.use(auth);
router.get('/', ctrl.getWallet);
router.post('/recharge', ctrl.recharge);
router.get('/transactions', ctrl.getTransactions);
router.get('/withdrawal-info', ctrl.getWithdrawalInfo);
router.post('/withdraw', ctrl.withdraw);

module.exports = router;
