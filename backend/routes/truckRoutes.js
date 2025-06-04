const express = require("express");
const router = express.Router();
const TruckController = require("../controllers/truckController");
const { protect } = require("../middleware/authMiddleware");
const { authorizeRoles } = require("../middleware/roleMiddleware");

router.get("/public", TruckController.getAllPublicTrucks);
router.get('/cuisines', TruckController.getAllCuisines);

router.use(protect);


router.get("/",  TruckController.getAllTrucks);

router.put("/admin/:id",authorizeRoles("admin"),TruckController.adminUpdateTruck);

router.delete("/admin/:id", authorizeRoles("admin"), TruckController.adminDeleteTruck);

router.get("/total", authorizeRoles("admin"), TruckController.getTotalTrucks); // Admin gets total truck count

router.post( "/", authorizeRoles("truck owner", "admin"),TruckController.createTruck);

router.get("/my-trucks",authorizeRoles("truck owner", "admin"), TruckController.getMyTrucks);

router.get("/:id",authorizeRoles("truck owner", "admin"),TruckController.getTruckById);

router.put("/:id",authorizeRoles("truck owner", "admin"),TruckController.updateTruck);

router.delete("/:id",authorizeRoles("truck owner", "admin"), TruckController.deleteTruck);

router.post("/:id/unavailable", authorizeRoles("truck owner"), TruckController.addUnavailableDate);

router.delete( "/:id/unavailable",authorizeRoles("truck owner"), TruckController.removeUnavailableDate);

module.exports = router;
