const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  userId: {
    type: String,
    required: true,
    unique: true,
  },
  phone: {
    type: String,
    required: true,
    unique: true,
  },
  name: {
    type: String,
    default: "",
  },
  avatar: {
    type: String,
    default: "",
  },
  gender: {
    type: String,
    default: "",
  },
  bio: {
    type: String,
    default: "",
  },
  country: {
    type: String,
    default: "India",
  },
  level: {
    type: Number,
    default: 1,
  },
  exp: {
    type: Number,
    default: 0,
  },
  vipLevel: {
    type: Number,
    default: 0,
  },
  coins: {
    type: Number,
    default: 0,
  },
  diamonds: {
    type: Number,
    default: 0,
  },
  followers: {
    type: Number,
    default: 0,
  },
  following: {
    type: Number,
    default: 0,
  },
  isBlocked: {
    type: Boolean,
    default: false,
  },
  isOnline: {
    type: Boolean,
    default: false,
  },
  lastLoginAt: {
    type: Date,
    default: Date.now,
  }
}, {
  timestamps: true,
});

module.exports = mongoose.model('User', userSchema);
