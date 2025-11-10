const express = require('express');
const router = express.Router();
const riwayatController = require('../controllers/riwayatPemeliharaanController');

router.get('/', riwayatController.getAllRiwayat);

module.exports = router;
