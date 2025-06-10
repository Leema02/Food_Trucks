const express = require("express");
const router = express.Router();
const TruckController = require("../controllers/truckController");
const { protect } = require("../middleware/authMiddleware");
const { authorizeRoles } = require("../middleware/roleMiddleware");

// ✅ Public
router.get("/public", TruckController.getAllPublicTrucks);
router.get("/cuisines", TruckController.getAllCuisines);

// ✅ Protected
router.use(protect);

// ✅ Append NEW admin-safe routes BEFORE /:id
router.get("/admin-search", authorizeRoles("admin"), TruckController.getTrucksForAdmin);
router.get("/admin/:id", authorizeRoles("admin"), TruckController.getAdminTruckById);

// ✅ Continue original working routes
router.get("/", TruckController.getAllTrucks);
router.put("/admin/:id", authorizeRoles("admin"), TruckController.adminUpdateTruck);
router.delete("/admin/:id", authorizeRoles("admin"), TruckController.adminDeleteTruck);
router.get("/total", authorizeRoles("admin"), TruckController.getTotalTrucks);

router.post("/", authorizeRoles("truck owner", "admin"), TruckController.createTruck);
router.get("/my-trucks", authorizeRoles("truck owner", "admin"), TruckController.getMyTrucks);

// ✅ DO NOT TOUCH THIS — required by Explore
router.get("/:id", TruckController.getTruckById);

router.put("/:id", authorizeRoles("truck owner", "admin"), TruckController.updateTruck);
router.delete("/:id", authorizeRoles("truck owner", "admin"), TruckController.deleteTruck);
router.post("/:id/unavailable", authorizeRoles("truck owner"), TruckController.addUnavailableDate);
router.delete("/:id/unavailable", authorizeRoles("truck owner"), TruckController.removeUnavailableDate);

module.exports = router;
