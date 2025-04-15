const Truck = require('../models/truckModel');

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

// 4. Delete truck
const deleteTruck = async (req, res) => {
  try {
    const truck = await Truck.findOneAndDelete({ _id: req.params.id, owner_id: req.user._id });

    if (!truck) return res.status(404).json({ message: 'Truck not found or not authorized' });

    res.json({ message: 'Truck deleted successfully' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

module.exports = {
  createTruck,
  getMyTrucks,
  updateTruck,
  deleteTruck
};
