// controllers/orderEstimateController.js
const OrderEstimate     = require('../models/OrderEstimate');
const { computeEstimate } = require('../services/estimateService');
const estimateService = require('../services/estimateService');

exports.calculateAndCreate = async (req, res, next) => {
  try {
    const { orderId } = req.params;
    const { maxConcurrent } = req.body;

    if (!maxConcurrent || isNaN(maxConcurrent)) {
      return res.status(400).json({ error: 'maxConcurrent is required and must be a number' });
    }

    const data = await computeEstimate(orderId, maxConcurrent);

    const estimate = await OrderEstimate.findOneAndUpdate(
      { orderId },
      { ...data, maxConcurrent, calculatedAt: new Date() },
      { upsert: true, new: true, setDefaultsOnInsert: true }
    );

    res.status(200).json({ success: true, estimate });
  } catch (err) {
    next(err);
  }
};


exports.getByOrder = async (req, res, next) => {
  try {
    const { orderId } = req.params;
    const estimate = await OrderEstimate.findOne({ orderId });
    if (!estimate) {
      return res.status(404).json({ success: false, message: 'No estimate found' });
    }
    res.json({ success: true, estimate });
  } catch (err) {
    next(err);
  }
};

exports.previewEstimate = async (req, res) => {
  try {
    const { truck_id, items, order_type } = req.body;

    // Validate input
    if (!truck_id || !Array.isArray(items) || items.length === 0) {
      return res.status(400).json({ success: false, message: 'Missing required fields' });
    }

    const estimatedTime = await estimateService.calculateEstimatePreview(truck_id, items, order_type);
    
    return res.json({ success: true, estimatedTimeInMinutes: estimatedTime });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ success: false, message: 'Error calculating estimate preview' });
  }
};

