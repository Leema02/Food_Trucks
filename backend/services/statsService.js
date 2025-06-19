// services/statsService.js
const Order            = require('../models/orderModel');
const PreparationStats = require('../models/PreparationStats');

/**
 * When an order goes Ready, record its actual prep time for each menu item.
 * @param {ObjectId} orderId
 */
async function recordPrepDuration(orderId) {
  const order = await Order.findById(orderId);
  if (!order) return;

  const { preparing: start, ready: end } = order.statusTimestamps;
  if (!start || !end) return;

  // minutes between statuses
  const delta = (end - start) / 60000;

  // for each item in the order, record the same delta
  await Promise.all(order.items.map(async item => {
    const menuItemId = item.menuItem; // assumes your items look like { menuItem, quantity }
    // push delta into that menuItem's stats
    const stat = await PreparationStats.findOneAndUpdate(
      { menuItemId },
      { $push: { times: delta } },
      { upsert: true, new: true }
    );
    // recompute avgTime
    const sum = stat.times.reduce((acc, v) => acc + v, 0);
    stat.avgTime = sum / stat.times.length;
    await stat.save();
  }));
}

module.exports = { recordPrepDuration };
