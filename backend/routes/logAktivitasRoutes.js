const express = require('express');
const router = express.Router();
const logAktivitasController = require('../controllers/logAktivitasController');

router.get('/log-aktivitas', logAktivitasController.getAllLog);
router.post('/log-aktivitas', logAktivitasController.createLog);

module.exports = router;
