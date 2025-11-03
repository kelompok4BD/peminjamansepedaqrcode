const express = require("express");
const router = express.Router();
const sepedaController = require("../controllers/sepedaController");

// Semua endpoint CRUD
router.get("/", sepedaController.getAllSepeda);
router.post("/", sepedaController.createSepeda);
router.put("/:id", sepedaController.updateStatus);
router.delete("/:id", sepedaController.deleteSepeda);

module.exports = router;
