const express = require('express');
const router = express.Router();
const laporanKerusakanController = require('../controllers/laporanKerusakanController');

// /api/laporan_kerusakan
router.get('/', laporanKerusakanController.getAllLaporan);
router.post('/', laporanKerusakanController.createLaporan);
router.put('/:id', laporanKerusakanController.updateStatus);

module.exports = router;
