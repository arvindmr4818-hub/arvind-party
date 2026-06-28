// =========================================================================
// MODULE: CREATOR ROUTES
// Merged from: creator.routes.js
// =========================================================================


// ─── FROM: creator.routes.js ────────────────────────────────────────
const express = require('express');
const router = express.Router();
const creatorController = require('../../controllers/creatorController');
const auth = require('../../middlewares/auth.middleware');

router.get('/earnings', auth, creatorController.getEarnings);
router.get('/analytics', auth, creatorController.getAnalytics);
router.post('/withdraw', auth, creatorController.withdrawEarnings);


module.exports = router;
