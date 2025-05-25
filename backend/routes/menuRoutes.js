const express = require('express');
const { createMenuItem, getMenuItemsByTruck, updateMenuItem, deleteMenuItem,getAllMenus } = require('../controllers/menuController');



const router = express.Router();
router.get('/all', getAllMenus);

router.post('/', createMenuItem);
router.get('/:truckId', getMenuItemsByTruck);
router.put('/:itemId', updateMenuItem);
router.delete('/:itemId', deleteMenuItem);
router.get('/all', getAllMenus);

module.exports = router;