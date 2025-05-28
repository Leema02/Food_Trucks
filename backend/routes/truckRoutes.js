const express = require('express');
const router = express.Router();
const TruckController = require('../controllers/truckController');
const { protect } = require('../middleware/authMiddleware');
const { authorizeRoles } = require('../middleware/roleMiddleware');

router.get('/public', TruckController.getAllPublicTrucks);// View trucks for customer

// 🛡️ All routes below require authentication
router.use(protect);

// 🚚 Only accessible by truck owners
router.post('/', authorizeRoles('truck owner', 'admin'), TruckController.createTruck); // Add new truck
router.get('/my-trucks', authorizeRoles('truck owner', 'admin'), TruckController.getMyTrucks); // View my trucks
router.put('/:id', authorizeRoles('truck owner', 'admin'), TruckController.updateTruck); // Update my truck
router.delete('/:id', authorizeRoles('truck owner', 'admin'), TruckController.deleteTruck); // Delete my truck
router.get('/:id', authorizeRoles('truck owner', 'admin'), TruckController.getTruckById);

// 🔴 Add unavailable date to truck
router.post('/:id/unavailable', authorizeRoles('truck owner'), TruckController.addUnavailableDate);
router.delete('/:id/unavailable', authorizeRoles('truck owner'), TruckController.removeUnavailableDate);

module.exports = router;

