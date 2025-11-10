const express = require("express");
const router = express.Router();
const userController = require("../controllers/userController");

router.get("/", userController.getAllUser);
router.put("/:id_NIM_NIP", userController.updateUser);
router.delete("/:id_NIM_NIP", userController.deleteUser);

module.exports = router;
