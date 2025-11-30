const express = require("express");
const router = express.Router();
const sepedaController = require("../controllers/sepedaController");

// Semua endpoint CRUD
router.get("/", sepedaController.getAllSepeda);
router.post("/", sepedaController.createSepeda);
router.put("/edit/:id", sepedaController.updateSepeda);
router.put("/:id", sepedaController.updateStatus);
router.delete("/:id", sepedaController.deleteSepeda);
router.post("/pinjam", sepedaController.pinjamSepeda);


module.exports = router;
