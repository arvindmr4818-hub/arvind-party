const mongoose = require('mongoose');

const connectDB = async () => {
  try {
    const conn = await mongoose.connect(process.env.MONGO_URI || 'mongodb://127.0.0.1:27017/arvind-party', {
      serverSelectionTimeoutMS: 5000, // 5 second timeout
    });
    console.log(`✅ MongoDB Connected: ${conn.connection.host}`);
    return true;
  } catch (error) {
    console.error(`⚠️ MongoDB Connection Error: ${error.message}`);
    console.log('⚠️ Server will continue running without database (using fallback data)');
    return false;
  }
};

module.exports = connectDB;
</content>
</invoke>
