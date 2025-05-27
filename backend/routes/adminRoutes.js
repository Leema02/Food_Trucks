const express = require("express");
const router = express.Router();

const { loginAdmin, registerAdmin } = require("../controllers/admincontroller");
const { protect } = require("../middleware/authMiddleware");
const { authorizeRoles } = require("../middleware/roleMiddleware");

// ✅ Public admin routes
router.post("/login", loginAdmin);

// ✅ Protected dashboard route
router.get(
  "/dashboard-data",
  protect,
  authorizeRoles("admin"), // ⬅️ Ensure this checks role_id === "admin"
  (req, res) => {
    res.json({
      totalOrders: 75,
      totalDelivered: 357,
      totalCanceled: 65,
      totalRevenue: 128,
    });
  }
);

module.exports = router;
