const express = require('express');
const {
  placeOrder,
  getMyOrders,
  getTruckOrders,
  updateOrderStatus
} = require('../controllers/orderController');
const { protect } = require('../middleware/authMiddleware');

const router = express.Router();

router.post('/', protect, placeOrder);
router.get('/my', protect, getMyOrders);
router.get('/truck/:truckId', protect, getTruckOrders);
router.put('/:id', protect, updateOrderStatus);

module.exports = router;
