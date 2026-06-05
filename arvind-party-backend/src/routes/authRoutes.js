const express = require('express');
const router = express.Router();
const { loginWithFirebase } = require('../controllers/authController');

router.post('/firebase-login', loginWithFirebase);

module.exports = router;
