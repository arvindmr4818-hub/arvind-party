const { Server } = require('socket.io');

let io;

const initializeSocket = (server) => {
    io = new Server(server, {
        cors: {
            origin: '*',
            methods: ['GET', 'POST']
        }
    });

    return io;
};

const getIO = () => {
    if (!io) {
        throw new Error('Socket Not Initialized');
    }
    return io;
};

module.exports = {
    initializeSocket,
    getIO
};
