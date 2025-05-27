const express = require('express');
const router = express.Router();
const {
  addTruckReview,
  getTruckReviews
} = require('../controllers/truckReviewController');
const {
  addMenuItemReview,
  getMenuItemReviews
} = require('../controllers/menuItemReviewController');
const { protect } = require('../middleware/authMiddleware');

// TRUCK REVIEWS
router.post('/truck', protect, addTruckReview);
router.get('/truck/:truckId', getTruckReviews);

// MENU ITEM REVIEWS
router.post('/menu', protect, addMenuItemReview);
router.get('/menu/:menuItemId', getMenuItemReviews);

module.exports = router;
