const express = require('express');
const router = express.Router();
const logAktivitasController = require('../controllers/logAktivitasController');

// /api/log_aktivitas
router.get('/', logAktivitasController.getAllLog);
router.post('/', logAktivitasController.createLog);

module.exports = router;
