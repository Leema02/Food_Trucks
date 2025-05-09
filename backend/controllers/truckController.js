const Truck = require('../models/truckModel');
const fs = require('fs');
const path = require('path');

// 1. Create new truck
const createTruck = async (req, res) => {
  try {
    const { truck_name, cuisine_type, description, logo_image_url, location, operating_hours } = req.body;

    const newTruck = new Truck({
      owner_id: req.user._id, // from auth middleware
      truck_name,
      cuisine_type,
      description,
      logo_image_url,
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

    Object.assign(truck, req.body); // merge updates
    const updated = await truck.save();

    res.json(updated);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

const deleteTruck = async (req, res) => {
  try {
    const truck = await Truck.findOne({ _id: req.params.id, owner_id: req.user._id });

    if (!truck) {
      return res.status(404).json({ message: 'Truck not found or not authorized' });
    }

    // 🧹 Try to delete the logo image if it exists
    if (truck.logo_image_url) {
      const logoPathPart = truck.logo_image_url.includes('/uploads/') 
        ? truck.logo_image_url.split('/uploads/')[1] 
        : null;

      if (logoPathPart) {
        const filePath = path.join(__dirname, '..', 'uploads', logoPathPart);
        if (fs.existsSync(filePath)) {
          fs.unlinkSync(filePath); // delete the file
          console.log('✅ Image deleted:', filePath);
        } else {
          console.log('⚠️ Image file not found, skipping deletion.');
        }
      }
    }

    // Then delete the truck from database
    await Truck.deleteOne({ _id: req.params.id, owner_id: req.user._id });

    res.json({ message: '✅ Truck and its image deleted successfully.' });
  } catch (err) {
    console.error('❌ Error deleting truck:', err);
    res.status(500).json({ message: 'Server error' });
  }
};

// Public route: Get all trucks for customer view
const getAllPublicTrucks = async (req, res) => {
  try {
    const trucks = await Truck.find({}, '-__v -updatedAt -createdAt'); // clean output
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
