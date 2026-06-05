const RoomSeat = require('../models/RoomSeat');
const RaiseHand = require('../models/RaiseHand');

module.exports = (io) => {
    io.on('connection', (socket) => {

        // Raise Hand
        socket.on('raise_hand', async (data) => {
            try {
                const request = await RaiseHand.create({
                    roomId: data.roomId,
                    userId: data.userId,
                    userName: data.userName
                });

                // Notify host/admins
                io.to(data.roomId).emit('new_raise_hand', request);
            } catch (error) {
                console.error('Raise hand error:', error);
            }
        });

        // Approve Raise Hand (Host Action)
        socket.on('approve_raise_hand', async (data) => {
            try {
                await RaiseHand.findByIdAndUpdate(data.requestId, { status: 'approved' });
                io.to(data.roomId).emit('raise_hand_approved', { userId: data.userId });
            } catch (error) {
                console.error('Approve raise hand error:', error);
            }
        });

        // Join Seat
        socket.on('join_seat', async (data) => {
            try {
                const seat = await RoomSeat.findOneAndUpdate(
                    { roomId: data.roomId, seatNumber: data.seatNumber },
                    { userId: data.userId, userName: data.userName },
                    { new: true, upsert: true }
                );
                io.to(data.roomId).emit('seat_updated', seat);
            } catch (error) {
                console.error('Join seat error:', error);
            }
        });

        // Leave Seat
        socket.on('leave_seat', async (data) => {
            try {
                const seat = await RoomSeat.findOneAndUpdate(
                    { roomId: data.roomId, seatNumber: data.seatNumber },
                    { userId: null, userName: '' },
                    { new: true }
                );
                io.to(data.roomId).emit('seat_updated', seat);
            } catch (error) {
                console.error('Leave seat error:', error);
            }
        });

        // Lock Seat
        socket.on('lock_seat', async (data) => {
            try {
                const seat = await RoomSeat.findOneAndUpdate(
                    { roomId: data.roomId, seatNumber: data.seatNumber },
                    { isLocked: true },
                    { new: true }
                );
                io.to(data.roomId).emit('seat_updated', seat);
            } catch (error) {
                console.error('Lock seat error:', error);
            }
        });

        // Unlock Seat
        socket.on('unlock_seat', async (data) => {
            try {
                const seat = await RoomSeat.findOneAndUpdate(
                    { roomId: data.roomId, seatNumber: data.seatNumber },
                    { isLocked: false },
                    { new: true }
                );
                io.to(data.roomId).emit('seat_updated', seat);
            } catch (error) {
                console.error('Unlock seat error:', error);
            }
        });

        // Mute Seat
        socket.on('mute_seat', async (data) => {
            try {
                const seat = await RoomSeat.findOneAndUpdate(
                    { roomId: data.roomId, seatNumber: data.seatNumber },
                    { isMuted: true },
                    { new: true }
                );
                io.to(data.roomId).emit('seat_updated', seat);
            } catch (error) {
                console.error('Mute seat error:', error);
            }
        });

        // Unmute Seat
        socket.on('unmute_seat', async (data) => {
            try {
                const seat = await RoomSeat.findOneAndUpdate(
                    { roomId: data.roomId, seatNumber: data.seatNumber },
                    { isMuted: false },
                    { new: true }
                );
                io.to(data.roomId).emit('seat_updated', seat);
            } catch (error) {
                console.error('Unmute seat error:', error);
            }
        });

    });
};
