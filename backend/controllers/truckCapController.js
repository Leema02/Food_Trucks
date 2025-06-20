const TruckCapacity = require('../models/truckCapacityModel');

exports.setCapacity = async (req, res, next) => {
  try {
    const { truckId, maxConcurrent } = req.body;

    // ✅ Basic validation
    if (!truckId || !maxConcurrent) {
      return res.status(400).json({
        success: false,
        message: 'truckId and maxConcurrent are required'
      });
    }

    // ✅ Upsert capacity entry
    const updatedCapacity = await TruckCapacity.findOneAndUpdate(
      { truckId },
      { maxConcurrent },
      { new: true, upsert: true, setDefaultsOnInsert: true }
    );

    res.status(200).json({
      success: true,
      message: 'Capacity saved successfully',
      data: updatedCapacity
    });

  } catch (error) {
    console.error('Error setting capacity:', error);
    next(error); // Pass to error handler middleware
  }
};


exports.getCapacityByTruckId = async (req, res, next) => {
  try {
    const { truckId } = req.params;

    const entry = await TruckCapacity.findOne({ truckId });
    if (!entry) {
      return res.status(404).json({ success: false, message: 'No capacity found for this truck' });
    }

    res.status(200).json({ success: true, data: entry });
  } catch (err) {
    next(err);
  }
};
