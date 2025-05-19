const express = require('express');
const router = express.Router();

const {
  createBooking,
  getMyBookings,
  getTruckBookings,
  updateBookingStatus,
  getAvailableTrucksByDate
} = require('../controllers/eventBookingController');

const { protect } = require('../middleware/authMiddleware');
const { authorizeRoles } = require('../middleware/roleMiddleware');

// 🔒 Auth required for all routes

// 🟢 Customer books an event
router.post('/', protect, authorizeRoles('customer'), createBooking);

// 🟡 Customer views their bookings
router.get('/my', protect, authorizeRoles('customer'), getMyBookings);

// 🔵 Truck owner views their truck's bookings
router.get('/owner', protect, authorizeRoles('truck owner'), getTruckBookings);

// 🔴 Truck owner updates booking status (approve/reject)
router.patch('/:id/status', protect, authorizeRoles('truck owner'), updateBookingStatus);

// 🟣 Anyone (usually customer) checks available trucks for a date
router.get('/available', protect, getAvailableTrucksByDate);

module.exports = router;
