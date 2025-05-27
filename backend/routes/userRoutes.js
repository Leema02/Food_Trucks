const express = require("express");
const router = express.Router();
const UserController = require("../controllers/userController");
const { protect } = require("../middleware/authMiddleware");
const { authorizeRoles } = require("../middleware/roleMiddleware");

router.post("/signup", UserController.signupUser);
router.post("/login", UserController.loginUser);
router.get("/verify-email", UserController.verifyEmail);
router.post("/forgot-password", UserController.forgotPassword);
//1- Email matched a user in the DB 2-Token was generated 3- Reset link was sent to the user's email
router.post("/verify-reset-code", UserController.verifyResetCode); 
 //Generate a code,,,Store it securely,,,Send it to the user’s email
router.post("/reset-password", UserController.resetPassword);

router.use(protect);
router.get("/", authorizeRoles("admin"), UserController.getAllUsers);
router.put("/:id", authorizeRoles("admin"), UserController.updateUser);

// ✅ DELETE USER
router.delete("/:id", authorizeRoles("admin"), UserController.deleteUser);

module.exports = router;
