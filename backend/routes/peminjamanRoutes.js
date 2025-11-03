const express = require("express");
const router = express.Router();
const peminjamanController = require("../controllers/peminjamanController");

// GET semua data peminjaman
router.get("/", peminjamanController.getAllPeminjaman);

// POST tambah peminjaman baru
router.post("/", peminjamanController.createPeminjaman);

// PUT update status peminjaman
router.put("/:id", peminjamanController.updateStatus);

module.exports = router;
