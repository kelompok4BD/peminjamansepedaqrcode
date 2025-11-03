const express = require("express");
const router = express.Router();
const userController = require("../controllers/userController");

// GET semua user
router.get("/", userController.getAllUser);

// POST tambah user baru
router.post("/", userController.createUser);

module.exports = router;
