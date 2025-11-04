const express = require('express');
const router = express.Router();
const stasiunController = require('../controllers/stasiunController');

router.get('/', stasiunController.getAllStasiun);

module.exports = router;
