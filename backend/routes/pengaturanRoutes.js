const express = require('express');
const router = express.Router();
const pengaturanController = require('../controllers/pengaturanController');

router.get('/', pengaturanController.getAllPengaturan);
router.get('/:id', pengaturanController.getPengaturanById);
router.put('/:id', pengaturanController.updatePengaturan);

module.exports = router;
