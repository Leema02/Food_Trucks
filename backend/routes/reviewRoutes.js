const express = require("express");
const router = express.Router();

const {
  addTruckReview,
  getTruckReviews,
  checkTruckRated,
  getAllTruckReviewsAdmin, // New
  deleteTruckReviewAdmin, // New
  getTruckReviewStatsAdmin, // New
} = require("../controllers/truckReviewController");

const {
  addMenuItemReview,
  getMenuItemReviews,
  checkMenuItemRated,
  getAllMenuItemReviewsAdmin, // New
  deleteMenuItemReviewAdmin, // New
  getMenuItemReviewStatsAdmin, // New
} = require("../controllers/menuItemReviewController");

const { protect } = require("../middleware/authMiddleware");
const { authorizeRoles } = require("../middleware/roleMiddleware"); // Make sure this is imported

// 🛡️ All routes below this line require authentication
router.use(protect);

// 👑 ADMIN ROUTES FOR REVIEWS (Place these before less specific routes if any)
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
); // Optional: Get stats

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
); // Optional: Get stats

// ===== CUSTOMER/GENERAL ROUTES FOR REVIEWS (Existing routes) =====
// TRUCK REVIEWS
router.post("/truck", addTruckReview);
router.get("/truck/:truckId", getTruckReviews);
router.get("/truck/check/:orderId/:truckId", checkTruckRated);

router.post("/menu", addMenuItemReview);
router.get("/menu/:menuItemId", getMenuItemReviews);
router.get("/menu/check/:orderId/:itemId", checkMenuItemRated); // Ensure this is AFTER /menu/:menuItemId

module.exports = router;
