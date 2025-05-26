const MenuItem = require('../models/menuModel');
const Truck = require('../models/truckModel');

// ✅ Create Menu Item
const createMenuItem = async (req, res) => {
  try {
    const {
      name,
      description,
      price,
      category,
      image_url,
      isAvailable,
      calories,
      isVegan,
      isSpicy
    } = req.body;

    const truckId = req.userTruckId || req.body.truck_id;

    const menuItem = new MenuItem({
      truck_id: truckId,
      name,
      description,
      price,
      category,
      image_url,
      isAvailable,
      calories,
      isVegan,
      isSpicy
    });

    const savedItem = await menuItem.save();
    res.status(201).json(savedItem);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// ✅ Get Menu Items for a Truck
const getMenuItemsByTruck = async (req, res) => {
  try {
    const items = await MenuItem.find({ truck_id: req.params.truckId });
    res.json(items);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// ✅ Update Menu Item
const updateMenuItem = async (req, res) => {
  try {
    const item = await MenuItem.findById(req.params.itemId);

    if (!item) return res.status(404).json({ message: 'Menu item not found' });

    Object.assign(item, req.body); // Will auto-update new fields
    const updatedItem = await item.save();

    res.json(updatedItem);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// ✅ Delete Menu Item
const deleteMenuItem = async (req, res) => {
  try {
    const item = await MenuItem.findByIdAndDelete(req.params.itemId);

    if (!item) return res.status(404).json({ message: 'Menu item not found' });

    res.json({ message: 'Menu item deleted successfully' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// GET /api/menus/all
const getAllMenus = async (req, res) => {
  try {
    const trucks = await Truck.find();

    const results = await Promise.all(
      trucks.map(async (truck) => {
        const menu = await MenuItem.find({ truck_id: truck._id });
        return {
          truckId: truck._id,
          truckName: truck.truck_name,
          menu
        };
      })
    );

    res.json(results);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};


module.exports = {
  createMenuItem,
  getMenuItemsByTruck,
  updateMenuItem,
  deleteMenuItem,
  getAllMenus
};
