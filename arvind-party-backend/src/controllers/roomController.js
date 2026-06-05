const Room = require('../models/Room');
const RoomMessage = require('../models/RoomMessage');
const crypto = require('crypto');

// Create a Room
exports.createRoom = async (req, res) => {
  try {
    const { title, description, coverImage, tags, language, roomType, password } = req.body;
    
    // Optional: limit to 1 active room per user
    let existingRoom = await Room.findOne({ ownerId: req.user.id, status: 'active' });
    if (existingRoom) {
       return res.status(400).json({ success: false, message: 'You already have an active room.', room: existingRoom });
    }

    const roomId = crypto.randomInt(100000, 999999).toString();

    const room = await Room.create({
      roomId,
      ownerId: req.user.id,
      title: title || 'My Voice Room',
      description: description || '',
      coverImage: coverImage || '',
      tags: tags || [],
      language: language || 'English',
      roomType: roomType || 'public',
      password: password || ''
    });

    return res.status(201).json({
      success: true,
      room
    });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
};

// Get List of Active Rooms
exports.getRooms = async (req, res) => {
  try {
    const rooms = await Room.find({ status: 'active', roomType: 'public' })
      .populate('ownerId', 'name avatar userId level')
      .sort({ activeUsers: -1, createdAt: -1 });

    return res.json({
      success: true,
      rooms
    });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
};

// Get Room Details
exports.getRoomDetails = async (req, res) => {
  try {
    const { roomId } = req.params;
    const room = await Room.findOne({ roomId })
      .populate('ownerId', 'name avatar userId level')
      .populate('seats.userId', 'name avatar userId level');

    if (!room) {
      return res.status(404).json({ success: false, message: 'Room not found' });
    }

    return res.json({
      success: true,
      room
    });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
};

// Join Room Verification
exports.joinRoom = async (req, res) => {
  try {
    const { roomId } = req.params;
    const { password } = req.body;

    const room = await Room.findOne({ roomId, status: 'active' });
    if (!room) {
      return res.status(404).json({ success: false, message: 'Room not found or inactive' });
    }

    if (room.roomType === 'private' && room.password !== password) {
      return res.status(401).json({ success: false, message: 'Invalid password' });
    }

    return res.json({
      success: true,
      message: 'Allowed to join room',
      room
    });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
};

// Get Room Messages
exports.getRoomMessages = async (req, res) => {
  try {
    const { roomId } = req.params;
    
    // Find the room to get its Object ID
    const room = await Room.findOne({ roomId });
    if (!room) {
      return res.status(404).json({ success: false, message: 'Room not found' });
    }

    // Get latest 50 messages
    const messages = await RoomMessage.find({ roomId: room._id })
      .sort({ createdAt: -1 })
      .limit(50);

    return res.json({
      success: true,
      messages: messages.reverse() // Return in chronological order
    });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
};
