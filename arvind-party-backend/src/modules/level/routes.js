// =========================================================================
// MODULE: LEVEL ROUTES
// Merged from: level.routes.js
// =========================================================================


// ─── FROM: level.routes.js ────────────────────────────────────────
const express = require('express');
const router = express.Router();
const levelController = require('../../controllers/levelController');
const auth = require('../../middlewares/auth.middleware');

router.get('/:id/level', auth, levelController.getUserLevel);
router.post('/xp/add', auth, levelController.addExperience);


module.exports = router;
