const express = require('express');
const router = express.Router();
const pegawaiController = require('../controllers/pegawaiController');

router.get('/pegawai', pegawaiController.getAllPegawai);
router.post('/pegawai', pegawaiController.createPegawai);

module.exports = router;
