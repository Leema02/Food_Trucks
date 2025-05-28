const express = require('express');
const router = express.Router();

const {
  addTruckReview,
  getTruckReviews,
  checkTruckRated
} = require('../controllers/truckReviewController');

const {
  addMenuItemReview,
  getMenuItemReviews,
  checkMenuItemRated
} = require('../controllers/menuItemReviewController');

const { protect } = require('../middleware/authMiddleware');

// ===== TRUCK REVIEWS =====
router.post('/truck', protect, addTruckReview);
router.get('/truck/:truckId', getTruckReviews);

// ✅ Check if customer already rated a truck for a specific order
router.get('/truck/check/:orderId/:truckId', protect, checkTruckRated);

// ===== MENU ITEM REVIEWS =====
router.post('/menu', protect, addMenuItemReview);
router.get('/menu/:menuItemId', getMenuItemReviews);

// ✅ Check if customer already rated a menu item for a specific order
router.get('/menu/check/:orderId/:itemId', protect, checkMenuItemRated);

module.exports = router;
