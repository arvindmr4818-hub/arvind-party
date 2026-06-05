const RoomMessage = require('../models/RoomMessage');

module.exports = (io) => {
    io.on('connection', (socket) => {
        socket.on('send_message', async (data) => {
            try {
                // Rate limiting/Spam check could be added here
                
                const msg = await RoomMessage.create({
                    roomId: data.roomId,
                    senderId: data.senderId,
                    senderName: data.senderName,
                    message: data.message,
                    messageType: 'text'
                });

                io.to(data.roomId).emit('receive_message', msg);
            } catch (error) {
                console.error('Error saving message:', error);
            }
        });
    });
};
