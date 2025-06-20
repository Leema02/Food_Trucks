// services/estimateService.js
const Order            = require('../models/orderModel');
const PreparationStats = require('../models/PreparationStats');

const DEFAULT_CONCURRENT   = parseInt(process.env.MAX_CONCURRENT_ORDERS, 10) || 5;
const DEFAULT_PREP_TIME    = parseInt(process.env.DEFAULT_PREP_TIME, 10)  || 10;

async function computeEstimate(orderId, maxConcurrentFromBody) {
  const order = await Order.findById(orderId);
  if (!order) throw new Error('Order not found');

  const truckId = order.truck_id.toString();
  const maxConcurrent = maxConcurrentFromBody || DEFAULT_CONCURRENT;

  // Part 1: slot‐free waiting time
  const preparingOrders = await Order.find({
    truck_id: truckId,
    status: 'Preparing'
  });

  let partOne = 0;
  if (preparingOrders.length >= maxConcurrent) {
    const now = Date.now();
    const remaining = await Promise.all(
      preparingOrders.map(async o => {
        const elapsed = (now - o.statusTimestamps.preparing) / 60000;
        const stats = await PreparationStats.findOne({ menuItemId: o.items[0].menu_id });
        const avgPrep = stats?.avgTime ?? DEFAULT_PREP_TIME;
        return Math.max(avgPrep - elapsed, 0);
      })
    );
    partOne = Math.min(...remaining);
  }

  // Part 2: this order’s own prep time
  const partTwoArr = await Promise.all(
    order.items.map(async item => {
      const stats = await PreparationStats.findOne({ menuItemId: item.menu_id });
      const avgTime = stats?.avgTime ?? DEFAULT_PREP_TIME;
      return avgTime * item.quantity;
    })
  );
  const partTwo = partTwoArr.reduce((sum, v) => sum + v, 0);

  return {
    partOne,
    partTwo,
    estimatedTime: partOne + partTwo,
    maxConcurrent
  };
}
module.exports = { computeEstimate };
