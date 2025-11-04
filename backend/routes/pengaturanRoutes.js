const express = require('express');
const router = express.Router();
const pengaturanController = require('../controllers/pengaturanController');

router.get('/', pengaturanController.getAllPengaturan);

module.exports = router;
