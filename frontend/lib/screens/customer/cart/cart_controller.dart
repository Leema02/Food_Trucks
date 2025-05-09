class CartController {
  static final List<Map<String, dynamic>> _cartItems = [];

  static String? get activeTruckId =>
      _cartItems.isNotEmpty ? _cartItems[0]['truck_id'] : null;

  static bool addToCart(Map<String, dynamic> item) {
    final truckId = item['truck_id'];

    // ❌ Block adding from a different truck
    if (_cartItems.isNotEmpty && truckId != activeTruckId) {
      return false; // signal "not allowed"
    }

    final existing =
        _cartItems.indexWhere((e) => e['menu_id'] == item['menu_id']);

    if (existing >= 0) {
      _cartItems[existing]['quantity'] += 1;
    } else {
      _cartItems.add({
        ...item,
        'quantity': 1,
        'truck_id': truckId,
      });
    }

    return true; // ✅ added successfully
  }

  static void removeFromCart(String menuId) {
    _cartItems.removeWhere((item) => item['menu_id'] == menuId);
  }

  static List<Map<String, dynamic>> getCartItems() => _cartItems;

  static double getTotal() {
    return _cartItems.fold(
      0.0,
      (sum, item) => sum + (item['price'] * item['quantity']),
    );
  }

  static void clearCart() => _cartItems.clear();
}
