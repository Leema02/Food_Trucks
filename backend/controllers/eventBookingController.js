const EventBooking = require("../models/eventBookingModel");
const Truck = require("../models/truckModel");
const Notification=require("../models/NotificationModel");
const User=require("../models/userModel");
const { sendToClient } = require("../services/CustomSocketService");
// 🟢 Create a new booking (multi-day)
const createBooking = async (req, res) => {
  try {
    const {
      event_start_date,
      event_end_date,
      start_time,
      end_time,
      occasion_type,
      location,
      city,
      guest_count,
      special_requests,
      total_amount,
      truck_id,
    } = req.body;

    if (
      !event_start_date ||
      !event_end_date ||
      new Date(event_start_date) > new Date(event_end_date)
    ) {
      return res.status(400).json({ message: "Invalid start or end date." });
    }

    // 🚨 Check for conflicts (any overlapping bookings)
    const conflict = await EventBooking.findOne({
      truck_id,
      status: { $in: ["pending", "confirmed"] },
      $or: [
        {
          event_start_date: { $lte: new Date(event_end_date) },
          event_end_date: { $gte: new Date(event_start_date) },
        },
      ],
    });

    if (conflict) {
      return res.status(400).json({
        message:
          "❌ This truck is already booked for part of the selected date range.",
      });
    }
    const booking = new EventBooking({
      user_id: req.user._id,
      truck_id,
      event_start_date,
      event_end_date,
      start_time,
      end_time,
      occasion_type,
      location,
      city,
      guest_count,
      special_requests,
      total_amount,
    });

    const saved = await booking.save();

    // 🔒 Block all booked days
    const truck = await Truck.findById(truck_id);
    const blocked = new Set(
      truck.unavailable_dates.map((d) => d.toISOString().split("T")[0])
    );
    const tempDate = new Date(event_start_date);
    const finalEnd = new Date(event_end_date);

    while (tempDate <= finalEnd) {
      blocked.add(tempDate.toISOString().split("T")[0]);
      tempDate.setDate(tempDate.getDate() + 1);
    }

    truck.unavailable_dates = Array.from(blocked).map(
      (dateStr) => new Date(dateStr)
    );
    await truck.save();
    const not =await Notification.create({
      userId:truck.owner_id,
      title:"New Booking Received",
      message:` New booking from ${req.user.F_name+" "+req.user.L_name} `
    });
    sendToClient(truck.owner_id.toString(),"Notification",not);
    res.status(201).json(saved);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// 🟡 Get my (customer) bookings
const getMyBookings = async (req, res) => {
  try {
    const bookings = await EventBooking.find({
      user_id: req.user._id,
    }).populate("truck_id");
    res.json(bookings);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// 🔵 Get bookings for a truck owner
const getTruckBookings = async (req, res) => {
  try {
    const ownerId = req.user._id;

    const trucks = await Truck.find({ owner_id: ownerId }).select("_id");
    const truckIds = trucks.map((t) => t._id);

    const bookings = await EventBooking.find({ truck_id: { $in: truckIds } })
      .populate("user_id", "F_name L_name email_address phone_num")
      .populate("truck_id", "truck_name")
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
      return res.status(404).json({ message: "Booking not found" });
    }

    const { status, total_amount } = req.body;

    if (status === "confirmed") {
      if (total_amount === undefined || isNaN(total_amount)) {
        return res.status(400).json({
          message:
            "Total amount is required and must be a number when confirming a booking.",
        });
      }
      booking.total_amount = total_amount;
    }

    if (status === "rejected" && booking.status !== "rejected") {
      const truck = await Truck.findById(booking.truck_id);
      const start = new Date(booking.event_start_date);
      const end = new Date(booking.event_end_date);
      const blockedToRemove = new Set();

      const temp = new Date(start);
      while (temp <= end) {
        blockedToRemove.add(temp.toISOString().split("T")[0]);
        temp.setDate(temp.getDate() + 1);
      }

      truck.unavailable_dates = truck.unavailable_dates.filter(
        (d) => !blockedToRemove.has(new Date(d).toISOString().split("T")[0])
      );

      await truck.save();
    }

    // ✅ Always update status here (even for rejected)
    booking.status = status;
    await booking.save();
    if(booking.status=="confirmed"){
      const not =await Notification.create({
        userId:booking.user_id,
        title:"Booking Accepted",
        message:`Your booking has been confirmed by Truck! `
      });
      sendToClient(booking.user_id.toString(),"Notification",not);
    }
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
      return res.status(404).json({ message: "Booking not found" });
    }

    if (booking.status !== "pending") {
      return res
        .status(400)
        .json({ message: "❌ Only pending bookings can be deleted." });
    }

    const isCustomer = booking.user_id.toString() === req.user._id.toString();
    const isTruckOwner = req.user.role_id === "truck owner";

    if (!isCustomer && !isTruckOwner) {
      return res
        .status(403)
        .json({ message: "Unauthorized to delete this booking" });
    }

    // 🧹 Unblock the dates
    const truck = await Truck.findById(booking.truck_id);
    const start = new Date(booking.event_start_date);
    const end = new Date(booking.event_end_date);
    const blockedToRemove = new Set();

    const temp = new Date(start);
    while (temp <= end) {
      blockedToRemove.add(temp.toISOString().split("T")[0]);
      temp.setDate(temp.getDate() + 1);
    }

    truck.unavailable_dates = truck.unavailable_dates.filter(
      (d) => !blockedToRemove.has(new Date(d).toISOString().split("T")[0])
    );

    await truck.save();
    await booking.deleteOne();
    if(isCustomer){
      const not =await Notification.create({
        userId:truck.owner_id,
        title:"Booking Cancelled",
        message:`Booking from  ${req.user.F_name+" "+req.user.L_name} was cancelled." `
      });
      sendToClient(truck.owner_id.toString(),"Notification",not);
    }
    else{
      const not =await Notification.create({
        userId:booking.user_id,
        title:"Booking Rejected",
        message:`The truck owner rejects the event `
      });
      sendToClient(booking.user_id.toString(),"Notification",not);
    }
    res.json({ message: "✅ Booking deleted and dates unblocked." });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};
// 🟣 Admin gets all bookings (for calendar view)
// 🟣 Admin gets all bookings (with optional date filter)
const getAllBookings = async (req, res) => {
  try {
 const { date } = req.query; // Extracts the date string (e.g., "2025-07-22")

    const query = {}; // Initialize an empty query object for MongoDB

    if (date) {
      const searchDateStr = date; // Incoming date string, e.g., "YYYY-MM-DD"

      // ⭐ CRITICAL FIX: Ensure correct UTC date range for the search day
      // These dates will represent the entire 24-hour period of the search day in UTC.
      const searchDayStart = new Date(searchDateStr);
      searchDayStart.setUTCHours(0, 0, 0, 0); // Set to midnight UTC of the search date

      const searchDayEnd = new Date(searchDateStr);
      searchDayEnd.setUTCHours(23, 59, 59, 999); // Set to just before midnight UTC of the *next* day


 query.$and = [
 { event_start_date: { $lte: searchDayEnd } },
 { event_end_date: { $gte: searchDayStart } },
    ];
 }
const bookings = await EventBooking.find(query) // <-- Pass the 'query' object here
      .populate("user_id", "F_name L_name")
      .populate("truck_id", "truck_name");

    res.status(200).json(bookings);
  } catch (err) {
    console.error("Error in getAllBookings (Admin):", err); // Keep this for debugging!
    res.status(500).json({ message: err.message });
  }
};

const getTotalBookings = async (req, res) => {
  try {
    const totalBookings = await EventBooking.countDocuments();
    res.status(200).json({ total: totalBookings }); // Return it as 'total' for consistency
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

module.exports = {
  createBooking,
  getMyBookings,
  getTruckBookings,
  updateBookingStatus,
  deleteBooking,
  getAllBookings,
  getTotalBookings,
};
