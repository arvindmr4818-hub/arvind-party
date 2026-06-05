const mongoose = require('mongoose');

const schema = new mongoose.Schema({
    giftId: String,
    name: String,
    image: String,
    price: Number,
    category: String,
    animationType: String,
    isActive: {
        type: Boolean,
        default: true
    }
});

module.exports = mongoose.model('Gift', schema);
