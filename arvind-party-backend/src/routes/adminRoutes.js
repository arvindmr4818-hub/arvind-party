const express = require('express');
const router = express.Router();
const adminAuth = require('../middlewares/adminMiddleware');
const ctrl = require('../controllers/adminController');

// Admin Login
router.post('/login', require('../controllers/adminAuthController').login);

// All below routes need admin auth
router.use(adminAuth);

// Dashboard
router.get('/dashboard', ctrl.getDashboard);

// Users
router.get('/users', ctrl.getUsers);
router.patch('/users/:id/block', ctrl.blockUser);
router.patch('/users/:id/unblock', ctrl.unblockUser);
router.post('/users/:id/coins', ctrl.addCoinsToUser);

// Rooms
router.get('/rooms', ctrl.getRooms);
router.patch('/rooms/:id/ban', ctrl.banRoom);
router.patch('/rooms/:id/close', ctrl.closeRoom);

// Gifts
router.get('/gifts', ctrl.getGifts);
router.post('/gifts', ctrl.createGift);
router.put('/gifts/:id', ctrl.updateGift);
router.delete('/gifts/:id', ctrl.deleteGift);

// Announcement
router.post('/announcement', ctrl.setAnnouncement);
router.get('/announcement', ctrl.getAnnouncement);

module.exports = router;
