const express = require('express');
const router = express.Router();

const {
  createBooking,
  getMyBookings,
  getTruckBookings,
  updateBookingStatus,
  deleteBooking,
  getAvailableTrucksByDate,
  getAllBookings,
} = require('../controllers/eventBookingController');

const { protect } = require('../middleware/authMiddleware');
const { authorizeRoles } = require('../middleware/roleMiddleware');

// 🔒 Auth required for all routes

// 🟢 Customer books an event
router.post('/', protect, authorizeRoles('customer'), createBooking);

// 🟡 Customer views their bookings
router.get('/my', protect, authorizeRoles('customer', 'admin'), getMyBookings);

// 🔵 Truck owner views their truck's bookings
router.get('/owner', protect, authorizeRoles('truck owner', 'admin'), getTruckBookings);

// 🔴 Truck owner updates booking status (approve/reject)
router.patch('/:id/status', protect, authorizeRoles('truck owner', 'admin'), updateBookingStatus);

// 🟤 Delete a booking (customer or owner)
router.delete('/:id', protect, deleteBooking);

// 🟣 Admin gets all bookings
router.get("/all", protect, authorizeRoles("admin"), getAllBookings);

module.exports = router;
