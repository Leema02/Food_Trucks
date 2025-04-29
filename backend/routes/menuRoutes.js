const express = require('express');
const { createMenuItem, getMenuItemsByTruck, updateMenuItem, deleteMenuItem } = require('../controllers/menuController');

const router = express.Router();

router.post('/', createMenuItem);
router.get('/:truckId', getMenuItemsByTruck);
router.put('/:itemId', updateMenuItem);
router.delete('/:itemId', deleteMenuItem);

module.exports = router;