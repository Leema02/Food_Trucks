const express = require("express");
const router = express.Router();
const UserController = require("../controllers/userController");
const { protect } = require("../middleware/authMiddleware");
const { authorizeRoles } = require("../middleware/roleMiddleware");

router.post("/signup", UserController.signupUser);
router.post("/login", UserController.loginUser);
router.get("/verify-email", UserController.verifyEmail);
router.post("/forgot-password", UserController.forgotPassword);
router.post("/verify-reset-code", UserController.verifyResetCode);
router.post("/reset-password", UserController.resetPassword);

router.use(protect);
router.get("/", authorizeRoles("admin"), UserController.getAllUsers);
router.put("/:id", authorizeRoles("admin"), UserController.updateUser);

// ✅ DELETE USER
router.delete("/:id", authorizeRoles("admin"), UserController.deleteUser);

module.exports = router;
