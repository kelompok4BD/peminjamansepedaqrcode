const express = require('express');
const router = express.Router();
const pegawaiController = require('../controllers/pegawaiController');

// /api/pegawai
router.get('/', pegawaiController.getAllPegawai);
router.post('/', pegawaiController.createPegawai);

module.exports = router;
