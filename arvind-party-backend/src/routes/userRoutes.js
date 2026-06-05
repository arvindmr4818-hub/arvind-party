// userRoutes.js
const express = require('express');
const router = express.Router();
const auth = require('../middlewares/authMiddleware');
const ctrl = require('../controllers/userController');

router.get('/me', auth, ctrl.getMe);
router.put('/me', auth, ctrl.updateMe);
router.get('/:userId', auth, ctrl.getUser);

module.exports = router;
