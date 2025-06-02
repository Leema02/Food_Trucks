const express = require('express');
const router = express.Router();
const controller = require('../controllers/reportController');
const { protect } = require("../middleware/authMiddleware");
const { authorizeRoles } = require("../middleware/roleMiddleware");
// Customers and owners report
router.post('/', protect, authorizeRoles('customer', 'truck owner'), controller.createReport);

// Admin views & updates
router.get('/', protect, authorizeRoles('admin'), controller.getAllReports);
router.put('/:id', protect, authorizeRoles('admin'), controller.updateReport);

module.exports = router;
