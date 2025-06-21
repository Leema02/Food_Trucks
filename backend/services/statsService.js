const Order = require('../models/orderModel');
const PreparationStats = require('../models/PreparationStats');

/**
 * When an order goes Ready, record its actual prep time for each menu item.
 * @param {ObjectId} orderId
 */
async function recordPrepDuration(orderId) {
  const order = await Order.findById(orderId);
  if (!order) {
    console.warn(`⚠️ Order not found: ${orderId}`);
    return;
  }

  const { preparing: start, ready: end } = order.statusTimestamps || {};
  if (!start || !end) {
    console.warn(`⚠️ Missing status timestamps on order ${orderId}`);
    return;
  }

  const delta = (end - start) / 60000; // duration in minutes

  await Promise.all(order.items.map(async item => {
    const menuItemId =   menuItemId; // Ensure you're using `menu_id` in your Order schema

    try {
      const stat = await PreparationStats.findOneAndUpdate(
        { menuItemId },
        { $push: { times: delta } },
        { upsert: true, new: true }
      );

      const times = stat.times || [];
      const sum = times.reduce((acc, v) => acc + v, 0);
      stat.avgTime = times.length ? sum / times.length : 0;

      await stat.save();
    } catch (err) {
      console.error(`❌ Error updating preparation stats for menuItemId ${menuItemId}:`, err.message);
    }
  }));
}

module.exports = { recordPrepDuration };
