const Order = require('../models/orderModel');
const User = require('../models/userModel');
const Truck = require('../models/truckModel');


// 🟢 Place a new order
const placeOrder = async (req, res) => {
  try {
    const { truck_id, items, total_price, order_type } = req.body;
    const customer_id = req.user._id;

    const customer = await User.findById(customer_id);
    const truck = await Truck.findById(truck_id);

    if (!customer || !truck) {
      return res.status(404).json({ message: 'Customer or truck not found' });
    }

    // ❌ Prevent cross-city ordering
    if (customer.city !== truck.city) {
      return res.status(400).json({
        message: 'You can only order from trucks in your city.',
      });
    }

    const newOrder = new Order({
      customer_id,
      truck_id,
      items,
      total_price,
      order_type
    });

    const savedOrder = await newOrder.save();
    res.status(201).json(savedOrder);

  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// 🟡 Get logged-in customer orders
const getMyOrders = async (req, res) => {
  try {
    const orders = await Order.find({ customer_id: req.user._id }).sort({ createdAt: -1 });
    res.json(orders);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// 🔵 Get orders for truck owner (by their trucks)
const getTruckOrders = async (req, res) => {
  try {
    const truckId = req.params.truckId;
    const orders = await Order.find({ truck_id: truckId })
      .populate('customer_id', 'F_name L_name') 
      .sort({ createdAt: -1 });

    res.json(orders);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// 🔴 Update order status
const updateOrderStatus = async (req, res) => {
  try {
    const order = await Order.findById(req.params.id);
    if (!order) return res.status(404).json({ message: 'Order not found' });

    order.status = req.body.status;
    await order.save();

    res.json(order);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

module.exports = {
  placeOrder,
  getMyOrders,
  getTruckOrders,
  updateOrderStatus
};
