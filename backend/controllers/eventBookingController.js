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

    // 🚨 Check for conflict: same truck, same date & time, pending or confirmed
    const existingBooking = await EventBooking.findOne({
      truck_id,
      event_date,
      event_time,
      status: { $in: ['pending', 'confirmed'] }
    });

    if (existingBooking) {
      return res.status(400).json({
        message: '❌ This truck is already booked for the selected date and time.'
      });
    }

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
      .populate('user_id', 'F_name L_name email_address phone_num')
      .populate('truck_id', 'truck_name') 
      .sort({ createdAt: -1 });

    res.json(bookings);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};
// 🔴 Truck Owner updates booking status (with total_amount required for confirmation)
const updateBookingStatus = async (req, res) => {
  try {
    const booking = await EventBooking.findById(req.params.id);
    if (!booking) {
      return res.status(404).json({ message: 'Booking not found' });
    }

    const { status, total_amount } = req.body;

    // Enforce total_amount for confirmation
    if (status === 'confirmed') {
      if (total_amount === undefined || isNaN(total_amount)) {
        return res.status(400).json({ message: 'Total amount is required and must be a number when confirming a booking.' });
      }
      booking.total_amount = total_amount;
    }

    booking.status = status;
    await booking.save();

    res.json({ message: `Booking ${status} successfully`, booking });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// 🟤 Delete a booking by ID (only if status is pending)
const deleteBooking = async (req, res) => {
  try {
    const booking = await EventBooking.findById(req.params.id);
    if (!booking) {
      return res.status(404).json({ message: 'Booking not found' });
    }

    // ❌ Only pending bookings can be deleted
    if (booking.status !== 'pending') {
      return res.status(400).json({ message: '❌ Only pending bookings can be deleted.' });
    }

    // 🛡 Only allow delete if requester is customer or truck owner
    const isCustomer = booking.user_id.toString() === req.user._id.toString();
    const isTruckOwner = req.user.role_id === 'truck owner';

    if (!isCustomer && !isTruckOwner) {
      return res.status(403).json({ message: 'Unauthorized to delete this booking' });
    }

    await booking.deleteOne();
    res.json({ message: '✅ Booking deleted successfully' });

  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

module.exports = {
  createBooking,
  getMyBookings,
  getTruckBookings,
  updateBookingStatus,
  deleteBooking
};
