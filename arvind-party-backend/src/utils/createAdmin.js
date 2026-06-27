// ═══════════════════════════════════════════════════════════════════════════
// ADMIN SEEDER — Creates the first owner account
// Run: node src/utils/createAdmin.js
// ═══════════════════════════════════════════════════════════════════════════

require('dotenv').config({ path: require('path').join(__dirname, '../../.env') });
const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

async function createAdmin() {
  try {
    await mongoose.connect(process.env.MONGO_URI);
    console.log('✅ Connected to MongoDB');

    // Dynamically require User model
    const User = require('../models/User.model');

    const existingAdmin = await User.findOne({ role: { $in: ['owner', 'super_admin'] } });
    if (existingAdmin) {
      console.log(`⚠️  Owner already exists: ${existingAdmin.name} (${existingAdmin.email})`);
      console.log('To reset password, run: node src/utils/resetAdminPassword.js');
      process.exit(0);
    }

    const password = process.env.ADMIN_PASSWORD || 'Admin@123456';
    const hashedPassword = await bcrypt.hash(password, 12);

    const admin = await User.create({
      name: 'Arvind Kumar',
      username: 'arvind_owner',
      email: process.env.SUPER_ADMIN_EMAIL || 'admin@arvindparty.com',
      phone: '9999999999',
      password: hashedPassword,
      role: 'owner',
      isActive: true,
      coins: 999999,
      diamonds: 999999,
      arvindId: 'OWNER001',
    });

    console.log('\n🎉 Owner account created successfully!');
    console.log('═══════════════════════════════════════');
    console.log(`Name:     ${admin.name}`);
    console.log(`Email:    ${admin.email}`);
    console.log(`Username: ${admin.username}`);
    console.log(`Password: ${password}`);
    console.log(`Role:     ${admin.role}`);
    console.log('═══════════════════════════════════════');
    console.log('\n⚠️  IMPORTANT: Change the password after first login!');
    console.log('Web Panel: http://localhost:YOUR_PORT (after flutter build)');

    process.exit(0);
  } catch (err) {
    console.error('❌ Error:', err.message);
    process.exit(1);
  }
}

createAdmin();
