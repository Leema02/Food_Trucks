const Truck = require('../models/truckModel');
const fs = require('fs');
const path = require('path');

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
      city // ⬅️ Required now
    } = req.body;

    if (!city) {
      return res.status(400).json({ message: 'City is required' });
    }

    const newTruck = new Truck({
      owner_id: req.user._id,
      truck_name,
      cuisine_type,
      description,
      logo_image_url,
      city, // ⬅️ Now included
      location,
      operating_hours
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

// 3. Update truck info
const updateTruck = async (req, res) => {
  try {
    const truck = await Truck.findOne({ _id: req.params.id, owner_id: req.user._id });

    if (!truck) return res.status(404).json({ message: 'Truck not found or not authorized' });

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
    const truck = await Truck.findOne({ _id: req.params.id, owner_id: req.user._id });

    if (!truck) {
      return res.status(404).json({ message: 'Truck not found or not authorized' });
    }

    // Delete logo file if it exists
    if (truck.logo_image_url) {
      const logoPathPart = truck.logo_image_url.includes('/uploads/')
        ? truck.logo_image_url.split('/uploads/')[1]
        : null;

      if (logoPathPart) {
        const filePath = path.join(__dirname, '..', 'uploads', logoPathPart);
        if (fs.existsSync(filePath)) {
          fs.unlinkSync(filePath);
          console.log('✅ Image deleted:', filePath);
        } else {
          console.log('⚠️ Image file not found, skipping deletion.');
        }
      }
    }

    await Truck.deleteOne({ _id: req.params.id, owner_id: req.user._id });

    res.json({ message: '✅ Truck and its image deleted successfully.' });
  } catch (err) {
    console.error('❌ Error deleting truck:', err);
    res.status(500).json({ message: 'Server error' });
  }
};

// 5. Public route: Get all trucks for customer view (with optional city filter)
const getAllPublicTrucks = async (req, res) => {
  try {
    const { city } = req.query;

    const filter = city
      ? { city: { $regex: new RegExp(`^${city}$`, 'i') } }
      : {};

    const trucks = await Truck.find(filter, '-__v -updatedAt -createdAt');
    res.json(trucks);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

module.exports = {
  createTruck,
  getMyTrucks,
  updateTruck,
  deleteTruck,
  getAllPublicTrucks
};
