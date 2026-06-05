const express = require('express');
const router = express.Router();
const auth = require('../middlewares/authMiddleware');
const ctrl = require('../controllers/walletController');

router.use(auth);
router.get('/', ctrl.getWallet);
router.post('/recharge', ctrl.recharge);
router.get('/transactions', ctrl.getTransactions);

module.exports = router;
