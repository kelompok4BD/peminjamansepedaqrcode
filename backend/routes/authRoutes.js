const express = require("express");
const router = express.Router();
const authController = require("../controllers/authController");

// Endpoint Login
router.post("/login", authController.login);

// Endpoint Register
router.post("/register", authController.register);

module.exports = router;
