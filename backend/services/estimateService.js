const axios = require('axios');
const Order = require('../models/orderModel');
const PreparationStats = require('../models/PreparationStats');

const DEFAULT_CONCURRENT = parseInt(process.env.MAX_CONCURRENT_ORDERS, 10) || 5;
const DEFAULT_PREP_TIME = parseInt(process.env.DEFAULT_PREP_TIME, 10) || 10;
const API_BASE_URL = process.env.API_BASE_URL || 'http://localhost:5000/api';

/**
 * Helper to fetch truck capacity via API
 */
async function getTruckCapacity(truckId) {
  try {
    const res = await axios.get(`${API_BASE_URL}/trucks/capacity/${truckId}`);
    return res.data?.data?.maxConcurrent ?? DEFAULT_CONCURRENT;
  } catch (err) {
    console.error(`❌ Error fetching capacity for truck ${truckId}:`, err.message);
    return DEFAULT_CONCURRENT;
  }
}


/**
 * Estimate time for an existing order by ID
 */
async function computeEstimate(orderId, maxConcurrentOverride) {
  const order = await Order.findById(orderId);
  if (!order) throw new Error('Order not found');

  const truckId = order.truck_id.toString();
  const maxConcurrent = maxConcurrentOverride || await getTruckCapacity(truckId);

  // Part 1: Waiting time due to concurrent order limit
  const activeOrders = await Order.find({ truck_id: truckId, status: 'Preparing' });

  let partOne = 0;
  if (activeOrders.length >= maxConcurrent) {
    const now = Date.now();

    const remainingTimes = await Promise.all(
      activeOrders.map(async (activeOrder) => {
        const startTime = activeOrder.statusTimestamps?.preparing || now;
        const elapsed = (now - startTime) / 60000;

        const firstItem = activeOrder.items[0];
        const stats = await PreparationStats.findOne({ menuItemId: firstItem.menu_id });
        const avgPrep = stats?.avgTime || DEFAULT_PREP_TIME;

        return Math.max(avgPrep - elapsed, 0);
      })
    );

    partOne = Math.min(...remainingTimes);
  }

  // Part 2: Current order’s own preparation time
  const partTwoPrepTimes = await Promise.all(
    order.items.map(async (item) => {
      const stats = await PreparationStats.findOne({ menuItemId: item.menu_id });
      const avgTime = stats?.avgTime || DEFAULT_PREP_TIME;
      return avgTime * item.quantity;
    })
  );

  const partTwo = partTwoPrepTimes.reduce((sum, val) => sum + val, 0);

  return {
    partOne,
    partTwo,
    estimatedTime: partOne + partTwo,
    maxConcurrent
  };
}

/**
 * Preview estimated time for a new (unsaved) order
 */
async function calculateEstimatePreview(truckId, items, orderType) {
  const maxConcurrent = await getTruckCapacity(truckId);

  const itemPrepTimes = await Promise.all(
    items.map(async (item) => {
      const stats = await PreparationStats.findOne({ menuItemId: item.menu_id });
      const avgTime = stats?.avgTime || DEFAULT_PREP_TIME;
      return avgTime * item.quantity;
    })
  );

  const totalPrepTime = itemPrepTimes.reduce((sum, time) => sum + time, 0);
  const estimatedTime = Math.ceil(totalPrepTime / maxConcurrent);

  return estimatedTime;
}

module.exports = {
  computeEstimate,
  calculateEstimatePreview
};