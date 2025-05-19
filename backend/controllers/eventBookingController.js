const EventBooking = require('../models/eventBookingModel');
const Truck = require('../models/truckModel');

// 🟢 Create a new booking
const createBooking = async (req, res) => {
  try {
    const {
      event_date,
      event_time,
      occasion_type,
      location,
      city,
      guest_count,
      special_requests,
      total_amount,
      truck_id
    } = req.body;

    const booking = new EventBooking({
      user_id: req.user._id,
      truck_id,
      event_date,
      event_time,
      occasion_type,
      location,
      city,
      guest_count,
      special_requests,
      total_amount
    });

    const saved = await booking.save();
    res.status(201).json(saved);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// 🟡 Get my (customer) bookings
const getMyBookings = async (req, res) => {
  try {
    const bookings = await EventBooking.find({ user_id: req.user._id }).populate('truck_id');
    res.json(bookings);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// 🔵 Get bookings for a truck owner
const getTruckBookings = async (req, res) => {
  try {
    const ownerId = req.user._id;

    const trucks = await Truck.find({ owner_id: ownerId }).select('_id');
    const truckIds = trucks.map(t => t._id);

    const bookings = await EventBooking.find({ truck_id: { $in: truckIds } })
      .populate('user_id', 'F_name L_name email_address')
      .sort({ createdAt: -1 });

    res.json(bookings);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// 🔴 Truck Owner updates booking status
const updateBookingStatus = async (req, res) => {
  try {
    const booking = await EventBooking.findById(req.params.id);
    if (!booking) return res.status(404).json({ message: 'Booking not found' });

    booking.status = req.body.status; // 'confirmed' or 'rejected'
    await booking.save();

    res.json(booking);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// 🟣 Optional: Get available trucks by date
const getAvailableTrucksByDate = async (req, res) => {
  try {
    const { event_date } = req.query;

    const bookedTrucks = await EventBooking.find({ event_date }).distinct('truck_id');

    const availableTrucks = await Truck.find({
      _id: { $nin: bookedTrucks }
    });

    res.json(availableTrucks);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

module.exports = {
  createBooking,
  getMyBookings,
  getTruckBookings,
  updateBookingStatus,
  getAvailableTrucksByDate
};
