const express = require("express");
const router = express.Router();
const TransaksiPeminjamanController = require("../controllers/transaksiPeminjamanController");

router.get("/", TransaksiPeminjamanController.getAll);
router.post("/", TransaksiPeminjamanController.create);
router.put("/:id/status", TransaksiPeminjamanController.updateStatus);

module.exports = router;
