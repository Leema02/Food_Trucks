const express = require('express');
const router = express.Router();

const {
  addTruckReview,
  getTruckReviews,
  checkTruckRated,
  getAllTruckReviewsAdmin,
  deleteTruckReviewAdmin,
  getTruckReviewStatsAdmin,
} = require('../controllers/truckReviewController'); 

const {
  addMenuItemReview,
  getMenuItemReviews,
  checkMenuItemRated,
  getAllMenuItemReviewsAdmin,
  deleteMenuItemReviewAdmin,
  getMenuItemReviewStatsAdmin,
  getMyMenuItemReviews,
} = require('../controllers/menuItemReviewController'); 
const { protect } = require('../middleware/authMiddleware'); 
const { authorizeRoles } = require("../middleware/roleMiddleware"); 

router.use(protect);
// ===== TRUCK REVIEWS =====
router.post('/truck', addTruckReview);
router.get('/truck/:truckId', getTruckReviews); 

// ✅ Check if customer already rated a truck for a specific order

router.get('/truck/check/:orderId/:truckId', checkTruckRated); 

// ===== MENU ITEM REVIEWS =====
router.get('/menu/my', protect, getMyMenuItemReviews);

router.post('/menu', addMenuItemReview); 
router.get('/menu/:menuItemId', getMenuItemReviews); 

// ✅ Check if customer already rated a menu item for a specific order
router.get('/menu/check/:orderId/:itemId', checkMenuItemRated); 



// TRUCK REVIEWS ADMIN
router.get("/admin/trucks", authorizeRoles("admin"), getAllTruckReviewsAdmin); 
router.delete(
  "/admin/trucks/:id",
  authorizeRoles("admin"),
  deleteTruckReviewAdmin
); 
router.get(
  "/admin/trucks/stats",
  authorizeRoles("admin"),
  getTruckReviewStatsAdmin
); 

// MENU ITEM REVIEWS ADMIN
router.get(
  "/admin/menu-items",
  authorizeRoles("admin"),
  getAllMenuItemReviewsAdmin
); 
router.delete(
  "/admin/menu-items/:id",
  authorizeRoles("admin"),
  deleteMenuItemReviewAdmin
); 
router.get(
  "/admin/menu-items/stats",
  authorizeRoles("admin"),
  getMenuItemReviewStatsAdmin
); 

module.exports = router;