// =========================================================================
// MODULE: USER ROUTES
// Merged from: user.routes.js, profileRoutes.js, socialRoutes.js, appUserRoutes.js
// =========================================================================


// ─── FROM: user.routes.js ────────────────────────────────────────
const express = require('express');
const router = express.Router();
const userController = require('../../controllers/userController');
const auth = require('../../middlewares/auth.middleware');

router.post('/complete-profile', auth, userController.updateProfile);
router.get('/center', auth, userController.getUserCenter);
router.post('/equip-frame', auth, userController.equipFrame);


// ─── FROM: profileRoutes.js ────────────────────────────────────────

const multer = require('multer');
const path = require('path');
const profileController = require('../../controllers/profileController');
const { authMiddleware, requireRole } = require('../../middlewares/auth.middleware');
const { checkBannedDevice } = require('../../middlewares/deviceFingerprint');

const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, path.join(__dirname, '../../uploads/avatars'));
  },
  filename: function (req, file, cb) {
    const ext = path.extname(file.originalname);
    const userId = req.params.userId;
    const timestamp = Date.now();
    cb(null, `avatar_${userId}_${timestamp}${ext}`);
  },
});

const fileFilter = (req, file, cb) => {
  const allowedTypes = ['image/jpeg', 'image/png', 'image/webp', 'image/gif'];
  if (allowedTypes.includes(file.mimetype)) {
    cb(null, true);
  } else {
    cb(new Error('Only JPEG, PNG, WebP, and GIF images are allowed'), false);
  }
};

const upload = multer({
  storage: storage,
  fileFilter: fileFilter,
  limits: { fileSize: 5 * 1024 * 1024 },
});

router.get('/:userId', authMiddleware, checkBannedDevice, profileController.getProfile);

router.put('/:userId', authMiddleware, checkBannedDevice, profileController.updateProfile);

router.post('/:userId/avatar', authMiddleware, checkBannedDevice, upload.single('avatar'), profileController.uploadAvatar);

router.get('/:userId/xp', authMiddleware, checkBannedDevice, profileController.getXpProgress);


// ─── FROM: socialRoutes.js ────────────────────────────────────────
const socialController = require('../../controllers/socialController');
const { authMiddleware } = require('../../middlewares/auth.middleware');

// ─────────────────────────────────────────────────────────────────────────
// SOCIAL ROUTES
// ─────────────────────────────────────────────────────────────────────────

// Follow user
router.post('/follow/:userId', authMiddleware, socialController.followUser);

// Unfollow user
router.post('/unfollow/:userId', authMiddleware, socialController.unfollowUser);

// Get followers list
router.get('/followers/:userId', authMiddleware, socialController.getFollowers);

// Get following list
router.get('/following/:userId', authMiddleware, socialController.getFollowing);

// Record profile visit
router.post('/visit/:userId', authMiddleware, socialController.recordVisit);

// Get visitor history
router.get('/visitors', authMiddleware, socialController.getVisitorHistory);

// Block user
router.post('/block/:userId', authMiddleware, socialController.blockUser);

// Unblock user
router.post('/unblock/:userId', authMiddleware, socialController.unblockUser);

// Get block list
router.get('/block-list', authMiddleware, socialController.getBlockList);

// Check block status
router.get('/check-block/:userId', authMiddleware, socialController.checkBlockStatus);


// ─── FROM: appUserRoutes.js ────────────────────────────────────────
const appUserController = require('../../controllers/appUserController');
const authMiddleware = require('../../middlewares/auth.middleware');

// App Users Routes — all require authentication
router.use(authMiddleware);

router.post('/join-agency', appUserController.joinAgency);
router.post('/withdraw', appUserController.requestWithdrawal);


module.exports = router;
