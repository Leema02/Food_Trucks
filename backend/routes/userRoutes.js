const express = require("express");
const router = express.Router();
const UserController = require("../controllers/userController");
const { protect } = require("../middleware/authMiddleware");
const { authorizeRoles } = require("../middleware/roleMiddleware");

// Public Routes
router.post("/signup", UserController.signupUser);
router.post("/login", UserController.loginUser);
router.get("/verify-email", UserController.verifyEmail);
router.post("/forgot-password", UserController.forgotPassword);
router.post("/verify-reset-code", UserController.verifyResetCode);
router.post("/reset-password", UserController.resetPassword);

// Protected Routes
router.use(protect);

// ✅ Admin-only: Get all users
router.get("/", authorizeRoles("admin"), UserController.getAllUsers);

// ✅ Admin-only: Get all users with search (new)
router.get("/admin-search", authorizeRoles("admin"), UserController.getAllUsersWithSearch);

// ✅ Admin-only: Get total users
router.get("/total", authorizeRoles("admin"), UserController.getTotalUsers);

// ✅ Admin-only: User signup statistics (new)
router.get("/signup-stats", authorizeRoles("admin"), UserController.getUserSignupStats);

// ✅ Admin-only: Update a user
router.put("/:id", authorizeRoles("admin"), UserController.updateUser);

// ✅ Admin-only: Delete a user
router.delete("/:id", authorizeRoles("admin"), UserController.deleteUser);

module.exports = router;
