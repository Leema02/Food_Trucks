const express = require("express");
const {
  placeOrder,
  getMyOrders,
  getTruckOrders,
  updateOrderStatus,
  getTotalOrders,
  getOrdersByTruck,
  getOrderTypesBreakdown, // ✅ You forgot to import this earlier
  getOrdersByCity,
  getPopularCuisines,
  getOrderStatusSummary,
  getAllOrders,
  getOrderById,
  deleteOrder,
} = require("../controllers/orderController");

const { protect } = require("../middleware/authMiddleware");
const { authorizeRoles } = require("../middleware/roleMiddleware");

const router = express.Router();

// 🟢 Customer places an order
router.post("/", protect, placeOrder);

// 🟡 Customer gets their own orders
router.get("/my", protect, getMyOrders);

// 🔵 Truck owner gets orders for a specific truck
router.get("/truck/:truckId", protect, getTruckOrders);

// 🔴 Update order status
router.put("/:id", protect, updateOrderStatus);

// 🟠 Admin gets total number of orders
router.get("/total", protect, authorizeRoles("admin"), getTotalOrders);

// 🟣 Admin: Orders by truck
router.get("/by-truck", protect, authorizeRoles("admin"), getOrdersByTruck);
router.get(
  "/popular-cuisines",
  protect,
  authorizeRoles("admin"),
  getPopularCuisines
);

// 🟤 Admin: Pie chart for order types breakdown
router.get(
  "/order-types",
  protect,
  authorizeRoles("admin"),
  getOrderTypesBreakdown
);
router.get(
  "/orders-by-city",
  protect,
  authorizeRoles("admin"),
  getOrdersByCity
);
router.get(
  "/popular-cuisines",
  protect,
  authorizeRoles("admin"),
  getPopularCuisines
);
router.get(
  "/status-summary",
  protect,
  authorizeRoles("admin"),
  getOrderStatusSummary
);
router.get("/", protect, authorizeRoles("admin"), getAllOrders);
router.get("/:id", protect, authorizeRoles("admin"), getOrderById);
router.delete("/:id", protect, authorizeRoles("admin"), deleteOrder);
module.exports = router;
