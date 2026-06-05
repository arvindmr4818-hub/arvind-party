const Room = require('../models/Room');
const roomOnlineUsers = {}; // roomId → Set of socketIds

module.exports = (io) => {
  io.on('connection', (socket) => {

    socket.on('join_room', async (data) => {
      const { roomId, userId, userName } = data;
      if (!roomId) return;

      socket.join(roomId);
      socket.roomId = roomId;
      socket.userId = userId;

      if (!roomOnlineUsers[roomId]) roomOnlineUsers[roomId] = new Set();
      roomOnlineUsers[roomId].add(socket.id);

      // DB mein activeUsers update karo
      await Room.findOneAndUpdate({ roomId }, { activeUsers: roomOnlineUsers[roomId].size });

      io.to(roomId).emit('room_message', {
        type: 'join', userName, message: `${userName} joined`
      });

      // KEY FIX: 'onlineUsers' key use karo (Flutter controller isi key se read karta hai)
      io.to(roomId).emit('room_online_update', {
        onlineUsers: roomOnlineUsers[roomId].size
      });
    });

    socket.on('leave_room', async (data) => {
      const { roomId, userId, userName } = data;
      if (!roomId) return;

      socket.leave(roomId);
      if (roomOnlineUsers[roomId]) {
        roomOnlineUsers[roomId].delete(socket.id);
        if (roomOnlineUsers[roomId].size === 0) delete roomOnlineUsers[roomId];
      }

      await Room.findOneAndUpdate(
        { roomId },
        { activeUsers: roomOnlineUsers[roomId]?.size || 0 }
      );

      io.to(roomId).emit('room_message', {
        type: 'leave', userName: userName || 'User', message: 'Left room'
      });

      io.to(roomId).emit('room_online_update', {
        onlineUsers: roomOnlineUsers[roomId]?.size || 0
      });
    });

    socket.on('disconnect', async () => {
      const roomId = socket.roomId;
      if (roomId && roomOnlineUsers[roomId]) {
        roomOnlineUsers[roomId].delete(socket.id);
        io.to(roomId).emit('room_online_update', {
          onlineUsers: roomOnlineUsers[roomId].size
        });
        await Room.findOneAndUpdate(
          { roomId },
          { activeUsers: roomOnlineUsers[roomId].size }
        );
      }
    });
  });
};
