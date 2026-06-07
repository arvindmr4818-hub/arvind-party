const User = require('../models/User');
const jwt = require('jsonwebtoken');

// Temporary in-memory OTP store (In Production, use Redis)
const otpStore = new Map();

exports.login = async (req, res) => {
  try {
    const { phone, otp } = req.body;
    if (!phone || !otp) return res.status(400).json({ message: 'Phone and OTP are required' });

    const storedOtp = otpStore.get(phone);
    if (!storedOtp || storedOtp !== otp) {
      return res.status(401).json({ message: 'Invalid OTP' });
    }

    // Find or create user
    let user = await User.findOne({ phone });
    if (!user) {
      user = new User({
        uid: `phone_${phone}`,
        provider: 'phone',
        phone: phone,
        name: `User ${phone.slice(-4)}`,
        arvindId: Math.floor(10000000 + Math.random() * 90000000).toString()
      });
      await user.save();
    }

    // Generate JWT token
    const token = jwt.sign(
      { userId: user._id, phone: user.phone },
      process.env.JWT_SECRET || 'arvind-party-secret',
      { expiresIn: '30d' }
    );

    otpStore.delete(phone); // Clear OTP after successful login

    res.status(200).json({
      message: 'Login successful',
      token,
      user: {
        id: user._id,
        name: user.name,
        phone: user.phone,
        arvindId: user.arvindId,
        avatar: user.avatar,
        isProfileComplete: user.isProfileComplete
      }
    });
  } catch (error) {
    console.error('Login Error:', error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
};

exports.sendOtp = async (req, res) => {
  try {
    const { phone } = req.body;
    if (!phone) return res.status(400).json({ message: 'Phone number is required' });

    // Generate 6-digit OTP (Static '123456' for test accounts like Apple/Google Reviewers)
    const otp = phone.endsWith('0000000000') ? '123456' : Math.floor(100000 + Math.random() * 900000).toString();
    
    // Store OTP with a 5-minute expiration
    otpStore.set(phone, { otp, expiresAt: Date.now() + 5 * 60 * 1000 });
    
    // TODO: Integrate AWS SNS, Twilio, or Firebase Admin here to send SMS
    console.log(`[DEV ONLY] OTP for ${phone} is: ${otp}`);

    res.status(200).json({ success: true, message: 'OTP sent successfully' });
  } catch (error) {
    console.error('Send OTP Error:', error);
    res.status(500).json({ message: 'Failed to send OTP' });
  }
};

exports.verifyOtp = async (req, res) => {
  try {
    const { phone, otp } = req.body;
    
    const record = otpStore.get(phone);
    if (!record || record.otp !== otp || Date.now() > record.expiresAt) {
      return res.status(400).json({ message: 'Invalid or expired OTP' });
    }

    // OTP is valid, remove it
    otpStore.delete(phone);

    // Check MongoDB for existing user
    let user = await User.findOne({ phone });
    const isNewUser = !user;
    
    if (isNewUser) {
      user = await User.create({ phone, isProfileComplete: false });
    }

    // Generate JWT Session Token
    const token = jwt.sign({ userId: user._id }, process.env.JWT_SECRET || 'supersecret_arvind_party', { expiresIn: '30d' });

    res.status(200).json({ success: true, token, isNewUser });
  } catch (error) {
    console.error('Verify OTP Error:', error);
    res.status(500).json({ message: 'Failed to verify OTP' });
  }
};