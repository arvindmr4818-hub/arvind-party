const User = require('../models/User');
const Gift = require('../models/Gift');
const GiftTransaction = require('../models/GiftTransaction');

module.exports = (io) => {
    io.on('connection', (socket) => {
        socket.on('send_gift', async (data) => {
            try {
                const { roomId, senderId, receiverId, giftId, quantity } = data;

                // Validate inputs
                if (!roomId || !senderId || !receiverId || !giftId || !quantity) {
                    return socket.emit('gift_error', { message: 'Missing required fields' });
                }

                // Retrieve entities
                const sender = await User.findById(senderId);
                const receiver = await User.findById(receiverId);
                const gift = await Gift.findById(giftId);

                if (!sender || !receiver || !gift) {
                    return socket.emit('gift_error', { message: 'Invalid user or gift' });
                }

                // Calculate cost and income
                const totalCoins = gift.price * quantity;
                const diamondsEarned = Math.floor(totalCoins * 0.6); // Host gets 60%

                // Check wallet balance
                if (sender.coins < totalCoins) {
                    return socket.emit('gift_error', { message: 'Insufficient coins' });
                }

                // Deduct coins & add diamonds
                sender.coins -= totalCoins;
                receiver.diamonds += diamondsEarned;

                await sender.save();
                await receiver.save();

                // Record transaction
                await GiftTransaction.create({
                    roomId,
                    senderId,
                    receiverId,
                    giftId,
                    quantity,
                    totalCoins,
                    diamondsEarned
                });

                // Broadcast animation
                io.to(roomId).emit('gift_animation', {
                    senderId: sender._id,
                    senderName: sender.name || sender.userId,
                    receiverId: receiver._id,
                    receiverName: receiver.name || receiver.userId,
                    giftId: gift._id,
                    giftName: gift.name,
                    giftImage: gift.image,
                    price: gift.price,
                    quantity: quantity,
                    animationType: gift.animationType,
                    combo: quantity // Simplified combo representing total sent this time
                });

            } catch (error) {
                console.error('Gift sending error:', error);
                socket.emit('gift_error', { message: 'Internal server error' });
            }
        });
    });
};
