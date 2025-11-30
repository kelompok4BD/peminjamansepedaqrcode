const express = require("express");
const router = express.Router();
const stasiunController = require("../controllers/stasiunSepedaController");

router.get("/", stasiunController.getAllStasiun);
router.get("/:id", stasiunController.getStasiunById);
router.post("/", stasiunController.createStasiun);
router.put("/:id", stasiunController.updateStasiun);
router.delete("/:id", stasiunController.deleteStasiun);

module.exports = router;
