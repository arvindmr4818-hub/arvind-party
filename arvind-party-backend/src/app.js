const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const errorHandler = require('./middlewares/errorHandler.middleware');
const corsConfig = require('./config/cors');
const requestLoggerMiddleware = require('./middlewares/request-logger.middleware');
const Logger = require('./utils/logger');

// ─── IMPORTING ALL PRODUCTION ROUTES ───────────────────────────────────────
const authRoutes = require('./routes/auth.routes');
const authSecureRoutes = require('./routes/authSecure.routes');
const googleAuthRoutes = require('./routes/googleAuthRoutes');
const firebaseAuthRoutes = require('./routes/firebaseAuth.routes');
const socialAuthRoutes = require('./routes/socialAuthRoutes');
const socialRoutes = require('./routes/socialRoutes'); // FIX: was missing import
const userRoutes = require('./routes/user.routes');
const adminRoutes = require('./routes/adminRoutes');
const staffRoutes = require('./routes/staffRoutes');
const securityRoutes = require('./routes/securityRoutes');
const roomRoutes = require('./routes/room.routes');
const giftRoutes = require('./routes/gift.routes');
const walletRoutes = require('./routes/wallet.routes');
const agencyRoutes = require('./routes/agencyRoutes');
const pkBattleRoutes = require('./routes/pkBattleRoutes');
const dealerRoutes = require('./routes/dealer.routes');
const attendanceRoutes = require('./routes/attendanceRoutes');
const salaryRoutes = require('./routes/salaryRoutes');
const agentRoutes = require('./routes/agentRoutes');
const withdrawalRoutes = require('./routes/withdrawalRoutes');
const penaltyRoutes = require('./routes/penaltyRoutes');
const bonusRoutes = require('./routes/bonusRoutes');
const reportsRoutes = require('./routes/reportsRoutes');
const familyRoutes = require('./routes/familyRoutes');
const shopRoutes = require('./routes/shopRoutes');
const gameRoutes = require('./routes/gameRoutes');
const webViewGameRoutes = require('./routes/webViewGameRoutes');
const cpRoutes = require('./routes/cpRoutes');
const treasuryRoutes = require('./routes/treasuryRoutes');
const matchmakingRoutes = require('./routes/matchmakingRoutes');
const rankingRoutes = require('./routes/rankingRoutes');
const vipRoutes = require('./routes/vipRoutes');
const vipSystemRoutes = require('./routes/vipSystemRoutes');
const chatRoutes = require('./routes/chatRoutes');
const appUserRoutes = require('./routes/appUserRoutes');
const levelRoutes = require('./routes/level.routes');
const agoraRoutes = require('./controllers/agoraController');
const inventoryRoutes = require('./routes/inventory.routes');
const creatorRoutes = require('./routes/creator.routes');
const supportRoutes = require('./routes/support.routes');
const moderationRoutes = require('./routes/moderation.routes');
const referralRoutes = require('./routes/referral.routes');
const momentRoutes = require('./routes/momentRoutes');
const notificationRoutes = require('./routes/notificationRoutes');
const agencyInvitationRoutes = require('./routes/agencyInvitationRoutes');
const eventRoutes = require('./routes/eventRoutes');
const tournamentRoutes = require('./routes/tournamentRoutes');
const treasureHuntRoutes = require('./routes/treasureHuntRoutes');
const targetRoutes = require('./routes/targetRoutes');
const luckyDrawRoutes = require('./routes/luckyDrawRoutes');
const dailyTaskRoutes = require('./routes/dailyTaskRoutes');
const inviteRoutes = require('./routes/inviteRoutes');
const loginStreakRoutes = require('./routes/loginStreakRoutes');
const analyticsRoutes = require('./routes/analytics.routes');
const healthRoutes = require('./routes/healthRoutes');
const moduleManagerRoutes = require('./routes/moduleManagerRoutes');
const localizationRoutes = require('./routes/localizationRoutes');
const infrastructureRoutes = require('./routes/infrastructureRoutes');
const profileRoutes = require('./routes/profileRoutes');
const antiBanRoutes = require('./routes/antiBanRoutes');
const roomFeaturesRoutes = require('./routes/roomFeaturesRoutes');
const youtubeRoutes = require('./routes/youtube.routes');

const app = express();

// ─── SECURITY MIDDLEWARES ─────────────────────────────────────────────────
app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      scriptSrc: ["'self'"],
      imgSrc: ["'self'", "data:", "https:"],
      connectSrc: ["'self'"],
      fontSrc: ["'self'"],
      objectSrc: ["'none'"],
      upgradeInsecureRequests: [],
    },
  },
  crossOriginEmbedderPolicy: false,
}));

app.use(requestLoggerMiddleware);
app.use(corsConfig);

// Body parsers
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// ─── RATE LIMITERS ────────────────────────────────────────────────────────
const apiLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 1000,
  standardHeaders: true,
  legacyHeaders: false,
  message: { success: false, message: 'Too many requests from this IP, please try again later.' }
});
app.use('/api/', apiLimiter);

const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 5,
  skipSuccessfulRequests: false,
  standardHeaders: true,
  legacyHeaders: false,
  message: { success: false, message: 'Too many login attempts. Please try again later.' }
});

const otpLimiter = rateLimit({
  windowMs: 1 * 60 * 1000,
  max: 3,
  skipSuccessfulRequests: false,
  message: { success: false, message: 'Too many OTP verification attempts. Please try again in 1 minute.' }
});

// ─── HEALTH & WELCOME ─────────────────────────────────────────────────────
app.get('/', (req, res) => {
  res.json({
    success: true,
    message: '🦁 ARVIND PARTY API Server',
    version: '1.0.0',
    status: 'running',
    timestamp: new Date().toISOString()
  });
});

app.get('/health', (req, res) => {
  res.json({
    success: true,
    status: 'healthy',
    uptime: process.uptime(),
    memoryUsage: process.memoryUsage(),
    timestamp: new Date().toISOString()
  });
});

app.use('/api/health', healthRoutes);

// ─── AUTH ROUTES ──────────────────────────────────────────────────────────
app.use('/api/auth', authLimiter, authRoutes);
app.use('/api/auth', authLimiter, authSecureRoutes);
app.use('/api/auth/social', googleAuthRoutes);
app.use('/api/auth/social', socialAuthRoutes);
app.use('/api/auth', authLimiter, firebaseAuthRoutes);

// ─── USER ROUTES ──────────────────────────────────────────────────────────
app.use('/api/users', userRoutes);
app.use('/api/social', socialRoutes);           // FIX: Follow, Unfollow, Block, Visitors
app.use('/api/profile', profileRoutes);
app.use('/api/app-users', appUserRoutes);

// ─── ADMIN & STAFF ────────────────────────────────────────────────────────
app.use('/api/admin', adminRoutes);
app.use('/api/admin/modules', moduleManagerRoutes);
app.use('/api/admin/anti-ban', antiBanRoutes);
app.use('/api/staff', staffRoutes);
app.use('/api/security', securityRoutes);
app.use('/api/moderation', moderationRoutes);
app.use('/api/support', supportRoutes);
app.use('/api/localization', localizationRoutes);
app.use('/api/infrastructure', infrastructureRoutes);

// ─── ROOM ROUTES ──────────────────────────────────────────────────────────
app.use('/api/rooms', roomRoutes);
app.use('/api/rooms/features', roomFeaturesRoutes);
app.use('/api/room', agoraRoutes);
app.use('/api/youtube', youtubeRoutes);
app.use('/api/pk-battles', pkBattleRoutes);

// ─── ECONOMY ROUTES ───────────────────────────────────────────────────────
app.use('/api/gifts', giftRoutes);
app.use('/api/wallet', walletRoutes);
app.use('/api/shop', shopRoutes);
app.use('/api/dealer', dealerRoutes);
app.use('/api/treasury', treasuryRoutes);
app.use('/api/inventory', inventoryRoutes);

// ─── AGENCY ROUTES ────────────────────────────────────────────────────────
app.use('/api/agency', agencyRoutes);
app.use('/api/agency', salaryRoutes);
app.use('/api/agency', agentRoutes);
app.use('/api/agency', withdrawalRoutes);
app.use('/api/agency', penaltyRoutes);
app.use('/api/agency', bonusRoutes);
app.use('/api/agency', reportsRoutes);
app.use('/api/agency', attendanceRoutes);
app.use('/api/agency/invitations', agencyInvitationRoutes);

// ─── SOCIAL & COMMUNICATION ───────────────────────────────────────────────
app.use('/api/chat', chatRoutes);
app.use('/api/family-chat', require('./routes/familyChatRoutes'));
app.use('/api/families', familyRoutes);
app.use('/api/moments', momentRoutes);
app.use('/api/notifications', notificationRoutes);
app.use('/api/referral', referralRoutes);

// ─── GAMING & EVENTS ──────────────────────────────────────────────────────
app.use('/api/games', gameRoutes);
app.use('/api/web-view-games', webViewGameRoutes);
app.use('/api/events', eventRoutes);
app.use('/api/tournaments', tournamentRoutes);
app.use('/api/treasure-hunts', treasureHuntRoutes);
app.use('/api/lucky-draws', luckyDrawRoutes);
app.use('/api/daily-tasks', dailyTaskRoutes);
app.use('/api/invites', inviteRoutes);
app.use('/api/login-streak', loginStreakRoutes);
app.use('/api/matchmaking', matchmakingRoutes);
app.use('/api/targets', targetRoutes);
app.use('/api/cp', cpRoutes);

// ─── VIP & PROGRESSION ────────────────────────────────────────────────────
app.use('/api/vip', vipRoutes);
app.use('/api/vip-system', vipSystemRoutes);
app.use('/api/level', levelRoutes);
app.use('/api/rankings', rankingRoutes);

// ─── OTHER ROUTES ─────────────────────────────────────────────────────────
app.use('/api/analytics', analyticsRoutes);
app.use('/api/creator', creatorRoutes);

// ─── 404 HANDLER ──────────────────────────────────────────────────────────
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: 'Route not found',
    path: req.path
  });
});

// ─── GLOBAL ERROR HANDLER (Must be LAST) ──────────────────────────────────
app.use(errorHandler);

module.exports = app;
