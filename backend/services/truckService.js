const Truck = require('../models/truckModel');

// 🔧 Add unavailable date
const addUnavailableDate = async (truckId, userId, date) => {
  if (!date) throw new Error('Date is required');

  const truck = await Truck.findById(truckId);
  if (!truck) throw new Error('Truck not found');

  if (truck.owner_id.toString() !== userId.toString()) {
    throw new Error('Unauthorized');
  }

  const exists = truck.unavailable_dates.find(d =>
    new Date(d).toDateString() === new Date(date).toDateString()
  );
  if (exists) throw new Error('Date already unavailable');

  truck.unavailable_dates.push(date);
  await truck.save();
  return truck;
};

const removeUnavailableDate = async (truckId, userId, date) => {
  if (!date) throw new Error('Date is required');

  const truck = await Truck.findById(truckId);
  if (!truck) throw new Error('Truck not found');

  if (truck.owner_id.toString() !== userId.toString()) {
    throw new Error('Unauthorized');
  }

  // Remove the matching date
  truck.unavailable_dates = truck.unavailable_dates.filter(d =>
    new Date(d).toDateString() !== new Date(date).toDateString()
  );

  await truck.save();
  return truck;
};

module.exports = {
  addUnavailableDate,
  removeUnavailableDate 
};
