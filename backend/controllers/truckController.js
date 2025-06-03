
const Truck = require("../models/truckModel");
const TruckReview = require("../models/truckReviewModel"); 

const fs = require("fs");
const path = require("path");
const truckService = require("../services/truckService");

// 1. Create new truck
const createTruck = async (req, res) => {
  try {
    const {
      truck_name,
      cuisine_type,
      description,
      logo_image_url,
      location,
      operating_hours,
      city, // ⬅️ Required now
    } = req.body;

    if (!city) {
      return res.status(400).json({ message: "City is required" });
    }

    const newTruck = new Truck({
      owner_id: req.user._id,
      truck_name, 
      cuisine_type,
      description,
      logo_image_url,
      city,
      location,
      operating_hours,
    });

    const savedTruck = await newTruck.save();
    res.status(201).json(savedTruck);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// 2. Get all trucks by logged-in owner

const getMyTrucks = async (req, res) => {
  try {
    const trucks = await Truck.find({ owner_id: req.user._id });

    res.json(trucks);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

const getTruckById = async (req, res) => {
  try {
    const truck = await Truck.findById(req.params.id);

    if (!truck) return res.status(404).json({ message: "Truck not found" });

    res.status(200).json(truck);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// 3. Update truck info

const updateTruck = async (req, res) => {
  try {
    const truck = await Truck.findOne({
      _id: req.params.id,

      owner_id: req.user._id,
    });

    if (!truck)
      return res

        .status(404)

        .json({ message: "Truck not found or not authorized" });

    Object.assign(truck, req.body);

    const updated = await truck.save();

    res.json(updated);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// 4. Delete truck + optional logo image

const deleteTruck = async (req, res) => {
  try {
    const truck = await Truck.findOne({
      _id: req.params.id,

      owner_id: req.user._id,
    });

    if (!truck) {
      return res

        .status(404)

        .json({ message: "Truck not found or not authorized" });
    } // Delete logo file if it exists

    if (truck.logo_image_url) {
      const logoPathPart = truck.logo_image_url.includes("/uploads/")
        ? truck.logo_image_url.split("/uploads/")[1]
        : null;

      if (logoPathPart) {
        const filePath = path.join(__dirname, "..", "uploads", logoPathPart);

        if (fs.existsSync(filePath)) {
          fs.unlinkSync(filePath);

          console.log("✅ Image deleted:", filePath);
        } else {
          console.log("⚠️ Image file not found, skipping deletion.");
        }
      }
    }

    await Truck.deleteOne({ _id: req.params.id, owner_id: req.user._id });

    res.json({ message: "✅ Truck and its image deleted successfully." });
  } catch (err) {
    console.error("❌ Error deleting truck:", err);

    res.status(500).json({ message: "Server error" });
  }
};

// 5. Public route: Get all trucks for customer view (with optional city filter)

const getAllPublicTrucks = async (req, res) => {
  try {
    const { city } = req.query;

    const matchFilter = city
      ? { city: { $regex: new RegExp(`^${city}$`, "i") } }
      : {};

    const trucks = await Truck.aggregate([
      { $match: matchFilter },

      // Join reviews
      {
        $lookup: {
          from: "truckreviews", // ✅ collection name (lowercase, plural usually)
          localField: "_id",
          foreignField: "truck_id",
          as: "reviews",
        },
      },

      // Calculate avg and count
      {
        $addFields: {
          average_rating: { $avg: "$reviews.rating" },
          review_count: { $size: "$reviews" },
        },
      },

      // Optional: hide unwanted fields
      {
        $project: {
          __v: 0,
          updatedAt: 0,
          createdAt: 0,
          reviews: 0, // to avoid sending the full review array
        },
      },
    ]);

    res.json(trucks);
  } catch (err) {
    console.error("❌ getAllPublicTrucks error:", err);
    res.status(500).json({ message: err.message });
  }
};

const addUnavailableDate = async (req, res) => {
  try {
    const truck = await truckService.addUnavailableDate(
      req.params.id,

      req.user._id,

      req.body.date
    );

    res.status(200).json({ message: "Date marked as unavailable", truck });
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
};

const removeUnavailableDate = async (req, res) => {
  try {
    const truck = await truckService.removeUnavailableDate(
      req.params.id,

      req.user._id,

      req.body.date
    );

    res.status(200).json({ message: "Unavailable date removed", truck });
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
};
const getAllTrucks = async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const skip = (page - 1) * limit;

    // 👇 Add search filters
    const { truck_name, city, cuisine_type } = req.query;
    const filter = {};
    if (truck_name) {
      filter.truck_name = { $regex: truck_name, $options: "i" };
    }
    if (city) {
      filter.city = { $regex: city, $options: "i" };
    }
    if (cuisine_type) {
      filter.cuisine_type = { $regex: cuisine_type, $options: "i" };
    }

    // 👇 Use the filter here (was missing in your version)
    const totalTrucks = await Truck.countDocuments(filter);

    const trucks = await Truck.find(filter)
      .populate("owner_id", "F_name L_name email_address")
      .skip(skip)
      .limit(limit);

    res.json({
      trucks,
      currentPage: page,
      totalPages: Math.ceil(totalTrucks / limit),
      totalItems: totalTrucks,
    });

  } catch (err) {
    console.error("Error in getAllTrucks (Admin):", err);
    res.status(500).json({ message: "Server error while fetching all trucks." });
  }
};


// Admin: Update any truck

const adminUpdateTruck = async (req, res) => {
  try {
    const { id } = req.params;

    const truck = await Truck.findById(id);

    if (!truck) {
      return res.status(404).json({ message: "Truck not found" });
    } // Apply updates from req.body

    Object.assign(truck, req.body);

    const updatedTruck = await truck.save();

    res.status(200).json(updatedTruck);
  } catch (err) {
    console.error("Error in adminUpdateTruck:", err);

    res.status(500).json({ message: "Server error while updating truck." });
  }
};

// Admin: Delete any truck

const adminDeleteTruck = async (req, res) => {
  try {
    const { id } = req.params;

    const truck = await Truck.findById(id);

    if (!truck) {
      return res.status(404).json({ message: "Truck not found" });
    } // Delete logo file if it exists (copy-pasted from deleteTruck for consistency)

    if (truck.logo_image_url) {
      const logoPathPart = truck.logo_image_url.includes("/uploads/")
        ? truck.logo_image_url.split("/uploads/")[1]
        : null;

      if (logoPathPart) {
        const filePath = path.join(__dirname, "..", "uploads", logoPathPart);

        if (fs.existsSync(filePath)) {
          fs.unlinkSync(filePath);

          console.log("✅ Admin: Image deleted:", filePath);
        } else {
          console.log("⚠️ Admin: Image file not found, skipping deletion.");
        }
      }
    }

    await truck.deleteOne();

    res.json({ message: "✅ Truck deleted by admin successfully." });
  } catch (err) {
    console.error("Error in adminDeleteTruck:", err);

    res.status(500).json({ message: "Server error while deleting truck." });
  }
};

// Admin: Get total number of trucks

const getTotalTrucks = async (req, res) => {
  try {
    const count = await Truck.countDocuments();

    res.status(200).json({ total: count });
  } catch (err) {
    console.error("Error in getTotalTrucks:", err);

    res.status(500).json({ message: err.message });
  }
};

// 🚚 Get all unique cuisine types
const getAllCuisines = async (req, res) => {
  try {
    const cuisines = await Truck.distinct('cuisine_type');
    res.status(200).json(cuisines);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};


module.exports = {
  createTruck,
  getMyTrucks,
  getTruckById,
  updateTruck,
  deleteTruck,
  getAllPublicTrucks,
  addUnavailableDate,
  removeUnavailableDate,
  getAllTrucks,
  adminUpdateTruck,
  adminDeleteTruck,
  getTotalTrucks,
  getAllCuisines

};
