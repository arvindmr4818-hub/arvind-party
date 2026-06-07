const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  uid: { type: String, required: true, unique: true }, // Firebase UID
  provider: { type: String, enum: ['phone', 'google', 'facebook', 'apple'], required: true },
  phone: { type: String, sparse: true },
  email: { type: String, sparse: true },
  name: { type: String, default: '' },
  avatar: { type: String, default: '' },
  arvindId: { type: String, unique: true }, // Unique 8-digit ID for Arvind Party
  isProfileComplete: { type: Boolean, default: false },
  diamonds: { type: Number, default: 0 },
  coins: { type: Number, default: 0 },
  vipLevel: { type: Number, default: 0 },
  level: { type: Number, default: 1 },
  badges: { type: [String], default: [] }, // List of badge IDs
  equippedFrame: { type: String, default: 'f1' }, // Currently equipped frame
  unlockedFrames: { type: [String], default: ['f1'] }, // List of unlocked frame IDs
  followersCount: { type: Number, default: 0 },
  followingCount: { type: Number, default: 0 },
  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date, default: Date.now }
});

// Automatically generate a random 8-digit Arvind ID before saving a new user
userSchema.pre('save', function(next) {
  if (!this.arvindId) {
    // Generate an ID like '83920194'
    this.arvindId = Math.floor(10000000 + Math.random() * 90000000).toString();
  }
  this.updatedAt = Date.now();
  next();
});

module.exports = mongoose.model('User', userSchema);