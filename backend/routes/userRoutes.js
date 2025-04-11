const express = require('express');
const router = express.Router();
const UserController = require('../controllers/userController');
const { protect } = require('../middleware/authMiddleware');
const { authorizeRoles } = require('../middleware/roleMiddleware');

router.post('/signup', UserController.signupUser ); //sign up
router.post('/login', UserController.loginUser); // login route
router.get('/verify-email', UserController.verifyEmail); 
router.post('/forgot-password', UserController.forgotPassword); //1- Email matched a user in the DB 2-Token was generated 3- Reset link was sent to the user's email
router.post('/reset-password/:token', UserController.resetPassword);

router.use(protect);
router.get('/', authorizeRoles('admin'), UserController.getAllUsers ); // Get all users


module.exports = router;
