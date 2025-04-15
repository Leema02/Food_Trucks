const express = require('express');
const router = express.Router();
const TruckController = require('../controllers/truckController');
const { protect } = require('../middleware/authMiddleware');
const { authorizeRoles } = require('../middleware/roleMiddleware');

// 🛡️ All routes below require authentication
router.use(protect);

// 🚚 Only accessible by truck owners
router.post('/', authorizeRoles('truck owner'), TruckController.createTruck); // Add new truck
router.get('/my-trucks', authorizeRoles('truck owner'), TruckController.getMyTrucks); // View my trucks
router.put('/:id', authorizeRoles('truck owner'), TruckController.updateTruck); // Update my truck
router.delete('/:id', authorizeRoles('truck owner'), TruckController.deleteTruck); // Delete my truck

module.exports = router;

