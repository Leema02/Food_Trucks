const Order = require("../models/orderModel");
const User = require("../models/userModel");
const Truck = require("../models/truckModel");

// 🟢 Place a new order
const placeOrder = async (req, res) => {
  try {
    const { truck_id, items, total_price, order_type } = req.body;
    const customer_id = req.user._id;

    const customer = await User.findById(customer_id);
    const truck = await Truck.findById(truck_id);

    if (!customer || !truck) {
      return res.status(404).json({ message: "Customer or truck not found" });
    }

    // ❌ Prevent cross-city ordering
    if (customer.city !== truck.city) {
      return res.status(400).json({
        message: "You can only order from trucks in your city.",
      });
    }

    const newOrder = new Order({
      customer_id,
      truck_id,
      items,
      total_price,
      order_type,
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
    const orders = await Order.find({ customer_id: req.user._id }).sort({
      createdAt: -1,
    });
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
      .populate("customer_id", "F_name L_name")
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
    if (!order) return res.status(404).json({ message: "Order not found" });

    order.status = req.body.status;
    await order.save();

    res.json(order);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

const getTotalOrders = async (req, res) => {
  try {
    const totalOrders = await Order.countDocuments();
    res.status(200).json({ totalOrders });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};
// Get order stats over time (grouped by date)
const getOrdersByTruck = async (req, res) => {
  try {
    const data = await Order.aggregate([
      {
        $group: {
          _id: "$truck_id",
          orderCount: { $sum: 1 },
        },
      },
      {
        $lookup: {
          from: "trucks",
          localField: "_id",
          foreignField: "_id",
          as: "truckInfo",
        },
      },
      {
        $unwind: "$truckInfo",
      },
      {
        $project: {
          truckName: "$truckInfo.truck_name",
          orderCount: 1,
        },
      },
      { $sort: { orderCount: -1 } },
    ]);

    res.status(200).json(data);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};
const getOrderTypesBreakdown = async (req, res) => {
  try {
    const result = await Order.aggregate([
      {
        $group: {
          _id: "$order_type",
          count: { $sum: 1 },
        },
      },
    ]);
    res.status(200).json(result);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};
const getOrdersByCity = async (req, res) => {
  try {
    const data = await Order.aggregate([
      {
        $lookup: {
          from: "users",
          localField: "customer_id",
          foreignField: "_id",
          as: "customerInfo",
        },
      },
      { $unwind: "$customerInfo" },
      {
        $group: {
          _id: "$customerInfo.city",
          count: { $sum: 1 },
        },
      },
      { $sort: { count: -1 } },
    ]);

    res.status(200).json(data);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};
const getPopularCuisines = async (req, res) => {
  try {
    const result = await Order.aggregate([
      { $unwind: "$items" },
      {
        $group: {
          _id: "$items.cuisine", // assumes each item has a "cuisine" field
          count: { $sum: 1 },
        },
      },
      {
        $project: {
          cuisine: "$_id",
          count: 1,
          _id: 0,
        },
      },
      { $sort: { count: -1 } },
    ]);

    res.status(200).json(result);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};
const getOrderStatusSummary = async (req, res) => {
  try {
    // Count documents for each status defined in your Order schema
    const pendingCount = await Order.countDocuments({
      status: { $regex: /^Pending$/i }, // Case-insensitive for 'Pending'
    });
    const preparingCount = await Order.countDocuments({
      status: { $regex: /^Preparing$/i }, // Case-insensitive for 'Preparing'
    });
    const readyCount = await Order.countDocuments({
      status: { $regex: /^Ready$/i }, // Case-insensitive for 'Ready'
    });
    const completedCount = await Order.countDocuments({
      status: { $regex: /^Completed$/i }, // Case-insensitive for 'Completed'
    });

    // Send back the counts with keys that match your frontend component's expectations
    res.status(200).json({
      pending: pendingCount,
      preparing: preparingCount,
      ready: readyCount,
      completed: completedCount,
    });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};
// Admin: Get all orders with pagination, filtering, and sorting
const getAllOrders = async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const skip = (page - 1) * limit;

    const query = {};
    if (req.query.status) {
      query.status = new RegExp(req.query.status, "i"); // Case-insensitive status filter
    }
    if (req.query.customer_id) {
      query.customer_id = req.query.customer_id;
    }
    if (req.query.truck_id) {
      query.truck_id = req.query.truck_id;
    }
    if (req.query.order_type) {
      query.order_type = new RegExp(req.query.order_type, "i");
    }

    const sort = {};
    if (req.query.sortBy && req.query.orderBy) {
      sort[req.query.sortBy] = req.query.orderBy === "desc" ? -1 : 1;
    } else {
      sort.createdAt = -1; // Default sort by newest first
    }

    const orders = await Order.find(query)
      .populate("customer_id", "F_name L_name email") // Populate customer info
      .populate("truck_id", "truck_name") // Populate truck info
      .sort(sort)
      .skip(skip)
      .limit(limit);

    const totalOrders = await Order.countDocuments(query);

    res.status(200).json({
      orders,
      totalPages: Math.ceil(totalOrders / limit),
      currentPage: page,
      totalOrders,
    });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};
const getOrderById = async (req, res) => {
  try {
    const order = await Order.findById(req.params.id)
      .populate("customer_id", "F_name L_name email phone")
      .populate("truck_id", "truck_name location contact_email");

    if (!order) {
      return res.status(404).json({ message: "Order not found" });
    }
    res.status(200).json(order);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};
const deleteOrder = async (req, res) => {
  try {
    const order = await Order.findById(req.params.id);
    if (!order) {
      return res.status(404).json({ message: "Order not found" });
    }
    await order.deleteOne(); // Use deleteOne() or deleteMany() depending on Mongoose version
    res.status(200).json({ message: "Order deleted successfully" });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

const getAllCustomersOrders = async (req, res) => {
  try {
    const customerId = req.params.customerId;
    const orders = await Order.find({ customer_id: customerId })
      .populate("truck_id", "truck_name")
      .sort({ createdAt: -1 });

    res.status(200).json(orders);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};
const getAllTrucksOrders = async (req, res) => {
  try {
    const truckId = req.params.truckId;
    const orders = await Order.find({ truck_id: truckId })
      .populate("customer_id", "F_name L_name email")
      .sort({ createdAt: -1 });

    res.status(200).json(orders);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};
const updateAnyOrderStatus = async (req, res) => {
  try {
    const { id } = req.params;
    const { status } = req.body;

    const order = await Order.findById(id);
    if (!order) return res.status(404).json({ message: "Order not found" });

    order.status = status;
    await order.save();

    res.status(200).json({ message: "Order status updated by admin", order });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

const adminSearchOrders = async (req, res) => {
  try {
    const {
      page = 1,
      limit = 10,
      status,
      order_type,
      customer_name,
      truck_name,
      sortBy = "createdAt",
      orderBy = "desc",
    } = req.query;

    const skip = (page - 1) * parseInt(limit);
    const sortDirection = orderBy === "desc" ? -1 : 1;

    const matchStage = {};

    if (status) matchStage.status = { $regex: new RegExp(status, "i") };
    if (order_type) matchStage.order_type = { $regex: new RegExp(order_type, "i") };

    const pipeline = [
      { $match: matchStage },
      {
        $lookup: {
          from: "users",
          localField: "customer_id",
          foreignField: "_id",
          as: "customer_id",
        },
      },
      { $unwind: "$customer_id" },
      {
        $lookup: {
          from: "trucks",
          localField: "truck_id",
          foreignField: "_id",
          as: "truck_id",
        },
      },
      { $unwind: "$truck_id" },
    ];

    if (customer_name) {
      pipeline.push({
        $match: {
          $or: [
            { "customer_id.F_name": { $regex: new RegExp(customer_name, "i") } },
            { "customer_id.L_name": { $regex: new RegExp(customer_name, "i") } },
          ],
        },
      });
    }

    if (truck_name) {
      pipeline.push({
        $match: {
          "truck_id.truck_name": { $regex: new RegExp(truck_name, "i") },
        },
      });
    }

    const totalPipeline = [...pipeline, { $count: "total" }];
    const totalCount = await Order.aggregate(totalPipeline);
    const totalOrders = totalCount[0]?.total || 0;
    const totalPages = Math.ceil(totalOrders / parseInt(limit));

    pipeline.push({ $sort: { [sortBy]: sortDirection } });
    pipeline.push({ $skip: skip });
    pipeline.push({ $limit: parseInt(limit) });

    const orders = await Order.aggregate(pipeline);

    res.json({ orders, totalOrders, totalPages, currentPage: parseInt(page) });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};


module.exports = {
  placeOrder,
  getMyOrders,
  getTruckOrders,
  updateOrderStatus,
  getTotalOrders,
  getOrdersByTruck,
  getOrderTypesBreakdown,
  getOrdersByCity,
  getPopularCuisines,
  getOrderStatusSummary,
  getAllOrders,
  getOrderById,
  deleteOrder,
  getAllCustomersOrders,
getAllTrucksOrders,
updateAnyOrderStatus,
  adminSearchOrders,

};
