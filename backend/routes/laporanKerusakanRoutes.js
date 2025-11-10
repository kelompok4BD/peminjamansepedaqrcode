const express = require('express');
const router = express.Router();
const laporanKerusakanController = require('../controllers/laporanKerusakanController');

router.get('/laporan-kerusakan', laporanKerusakanController.getAllLaporan);
router.post('/laporan-kerusakan', laporanKerusakanController.createLaporan);
router.put('/laporan-kerusakan/:id', laporanKerusakanController.updateStatus);

module.exports = router;
