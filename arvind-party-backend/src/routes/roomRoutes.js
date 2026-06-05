const express = require('express');
const router = express.Router();
const authMiddleware = require('../middlewares/authMiddleware');
const { createRoom, getRooms, getRoomDetails, joinRoom, getRoomMessages } = require('../controllers/roomController');

router.use(authMiddleware);

router.post('/', createRoom);
router.get('/', getRooms);
router.get('/:roomId', getRoomDetails);
router.post('/:roomId/join', joinRoom);
router.get('/:roomId/messages', getRoomMessages);

module.exports = router;
