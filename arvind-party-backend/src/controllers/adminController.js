const User = require('../models/User');
const Room = require('../models/Room');
const Gift = require('../models/Gift');
const GiftTransaction = require('../models/GiftTransaction');
const RoomMessage = require('../models/RoomMessage');
const Ranking = require('../models/Ranking');

// ─── DASHBOARD STATS ──────────────────────────────────────────────────────

exports.getDashboard = async (req, res) => {
  try {
    const [
      totalUsers, activeRooms, totalRooms,
      todayUsers, blockedUsers, totalGiftTx
    ] = await Promise.all([
      User.countDocuments(),
      Room.countDocuments({ status: 'active' }),
      Room.countDocuments(),
      User.countDocuments({ createdAt: { $gte: new Date(new Date().setHours(0,0,0,0)) } }),
      User.countDocuments({ isBlocked: true }),
      GiftTransaction.countDocuments()
    ]);

    const onlineUsers = await User.countDocuments({ isOnline: true });

    const recentUsers = await User.find()
      .sort({ createdAt: -1 }).limit(5)
      .select('name userId avatar level createdAt');

    const recentRooms = await Room.find()
      .sort({ createdAt: -1 }).limit(5)
      .populate('ownerId', 'name avatar')
      .select('roomId title activeUsers status createdAt');

    return res.json({
      success: true,
      stats: {
        totalUsers, activeRooms, totalRooms,
        todayUsers, blockedUsers, onlineUsers, totalGiftTx
      },
      recentUsers,
      recentRooms
    });
  } catch (e) {
    return res.status(500).json({ success: false, message: e.message });
  }
};

// ─── USER MANAGEMENT ─────────────────────────────────────────────────────

exports.getUsers = async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const search = req.query.search || '';
    const filter = {};
    if (search) filter.$or = [
      { name: { $regex: search, $options: 'i' } },
      { userId: { $regex: search, $options: 'i' } },
      { phone: { $regex: search, $options: 'i' } }
    ];
    if (req.query.blocked === 'true') filter.isBlocked = true;

    const users = await User.find(filter)
      .sort({ createdAt: -1 })
      .skip((page - 1) * limit).limit(limit);
    const total = await User.countDocuments(filter);

    return res.json({ success: true, users, total, page, pages: Math.ceil(total / limit) });
  } catch (e) {
    return res.status(500).json({ success: false, message: e.message });
  }
};

exports.blockUser = async (req, res) => {
  try {
    await User.findByIdAndUpdate(req.params.id, { isBlocked: true });
    return res.json({ success: true, message: 'User blocked' });
  } catch (e) {
    return res.status(500).json({ success: false, message: e.message });
  }
};

exports.unblockUser = async (req, res) => {
  try {
    await User.findByIdAndUpdate(req.params.id, { isBlocked: false });
    return res.json({ success: true, message: 'User unblocked' });
  } catch (e) {
    return res.status(500).json({ success: false, message: e.message });
  }
};

exports.addCoinsToUser = async (req, res) => {
  try {
    const { amount } = req.body;
    const user = await User.findByIdAndUpdate(
      req.params.id,
      { $inc: { coins: amount } },
      { new: true }
    );
    return res.json({ success: true, message: `${amount} coins added`, user });
  } catch (e) {
    return res.status(500).json({ success: false, message: e.message });
  }
};

// ─── ROOM MANAGEMENT ─────────────────────────────────────────────────────

exports.getRooms = async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const filter = {};
    if (req.query.status) filter.status = req.query.status;

    const rooms = await Room.find(filter)
      .populate('ownerId', 'name avatar userId')
      .sort({ createdAt: -1 })
      .skip((page - 1) * limit).limit(limit);
    const total = await Room.countDocuments(filter);

    return res.json({ success: true, rooms, total, page, pages: Math.ceil(total / limit) });
  } catch (e) {
    return res.status(500).json({ success: false, message: e.message });
  }
};

exports.banRoom = async (req, res) => {
  try {
    await Room.findByIdAndUpdate(req.params.id, { status: 'banned' });
    return res.json({ success: true, message: 'Room banned' });
  } catch (e) {
    return res.status(500).json({ success: false, message: e.message });
  }
};

exports.closeRoom = async (req, res) => {
  try {
    await Room.findByIdAndUpdate(req.params.id, { status: 'inactive' });
    return res.json({ success: true, message: 'Room closed' });
  } catch (e) {
    return res.status(500).json({ success: false, message: e.message });
  }
};

// ─── GIFT MANAGEMENT ─────────────────────────────────────────────────────

exports.getGifts = async (req, res) => {
  try {
    const gifts = await Gift.find().sort({ price: 1 });
    return res.json({ success: true, gifts });
  } catch (e) {
    return res.status(500).json({ success: false, message: e.message });
  }
};

exports.createGift = async (req, res) => {
  try {
    const gift = await Gift.create(req.body);
    return res.status(201).json({ success: true, gift });
  } catch (e) {
    return res.status(500).json({ success: false, message: e.message });
  }
};

exports.updateGift = async (req, res) => {
  try {
    const gift = await Gift.findByIdAndUpdate(req.params.id, req.body, { new: true });
    return res.json({ success: true, gift });
  } catch (e) {
    return res.status(500).json({ success: false, message: e.message });
  }
};

exports.deleteGift = async (req, res) => {
  try {
    await Gift.findByIdAndUpdate(req.params.id, { isActive: false });
    return res.json({ success: true, message: 'Gift deactivated' });
  } catch (e) {
    return res.status(500).json({ success: false, message: e.message });
  }
};

// ─── ANNOUNCEMENT ─────────────────────────────────────────────────────────

// Announcement global state (in-memory, production mein Redis mein rakhna)
let globalAnnouncement = '';

exports.setAnnouncement = async (req, res) => {
  globalAnnouncement = req.body.message || '';
  // Socket se sab users ko broadcast karo
  req.app.get('io')?.emit('global_announcement', { message: globalAnnouncement });
  return res.json({ success: true, message: 'Announcement sent' });
};

exports.getAnnouncement = async (req, res) => {
  return res.json({ success: true, announcement: globalAnnouncement });
};
