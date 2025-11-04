const express = require('express');
const router = express.Router();
const riwayatController = require('../controllers/riwayatPemeliharaanController');

// GET semua riwayat pemeliharaan
router.get('/', riwayatController.getAllRiwayat);

module.exports = router;
