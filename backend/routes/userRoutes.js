const express = require('express');
const router = express.Router();
const UserController = require('../controllers/userController');
const { protect } = require('../middleware/authMiddleware');
const { authorizeRoles } = require('../middleware/roleMiddleware');

router.post('/signup', authorizeRoles('customer', 'truck owner'),UserController.signupUser ); //sign up
router.post('/login', UserController.loginUser); // login route

router.use(protect);
router.get('/', authorizeRoles('admin'), UserController.getAllUsers ); // Get all users


module.exports = router;
