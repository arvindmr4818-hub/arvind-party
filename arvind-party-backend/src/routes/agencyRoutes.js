const express = require('express');
const router = express.Router();
const auth = require('../middlewares/auth.middleware');
const agencyController = require('../controllers/agencyController');

router.get('/mine', auth, agencyController.getMyAgency);
router.post('/apply', auth, agencyController.applyForAgency);

module.exports = router;
