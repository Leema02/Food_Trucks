const express = require("express");
const router = express.Router();
const TruckController = require("../controllers/truckController");
const { protect } = require("../middleware/authMiddleware");
const { authorizeRoles } = require("../middleware/roleMiddleware");

// Public routes
router.get("/public", TruckController.getAllPublicTrucks);
router.get('/cuisines', TruckController.getAllCuisines);

// Authenticated routes
router.use(protect);

// Admin-specific
router.get("/total", authorizeRoles("admin"), TruckController.getTotalTrucks);
router.get("/admin", authorizeRoles("admin"), TruckController.getAllTrucks); // ✅ must come BEFORE /:id

// NEW ADMIN ROUTES - ADDED HERE
router.get("/admin-search", authorizeRoles("admin"), TruckController.getTrucksForAdmin); // New route for admin search with filters and pagination
router.get("/admin/:id", authorizeRoles("admin"), TruckController.getAdminTruckById); // New route for admin to get a truck by ID

router.put("/admin/:id",authorizeRoles("admin"),TruckController.adminUpdateTruck);
router.delete("/admin/:id", authorizeRoles("admin"), TruckController.adminDeleteTruck);


// Truck owner
router.post( "/", authorizeRoles("truck owner", "admin"),TruckController.createTruck);
router.get("/my-trucks",authorizeRoles("truck owner", "admin"), TruckController.getMyTrucks);


// ⚠️ Move these LAST so they don't match earlier paths like /admin or /public
router.get("/:id",authorizeRoles("truck owner", "admin"),TruckController.getTruckById);
router.put("/:id",authorizeRoles("truck owner", "admin"),TruckController.updateTruck);
router.delete("/:id",authorizeRoles("truck owner", "admin"), TruckController.deleteTruck);
router.post("/:id/unavailable", authorizeRoles("truck owner"), TruckController.addUnavailableDate);
router.delete( "/:id/unavailable",authorizeRoles("truck owner"), TruckController.removeUnavailableDate);


module.exports = router;