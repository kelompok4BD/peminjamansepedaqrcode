const express = require("express");
const router = express.Router();
const stasiunController = require("../controllers/stasiunSepedaController");

router.get("/", stasiunController.getAllStasiun);

module.exports = router;
