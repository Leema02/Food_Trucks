class CartController {
  static final List<Map<String, dynamic>> _cartItems = [];

  static String? get activeTruckId =>
      _cartItems.isNotEmpty ? _cartItems[0]['truck_id'] : null;

  static String? get activeTruckCity =>
      _cartItems.isNotEmpty ? _cartItems[0]['truck_city'] : null;

  /// Add item to cart
  /// Returns false if item belongs to a different truck
  static bool addToCart(Map<String, dynamic> item) {
    final truckId = item['truck_id'];
    final truckCity = item['truck_city'];

    if (truckId == null || truckCity == null) {
      throw ArgumentError("Missing truck_id or truck_city in cart item");
    }

    // ❌ Prevent adding from a different truck
    if (_cartItems.isNotEmpty && truckId != activeTruckId) {
      return false;
    }

    final index = _cartItems.indexWhere((e) => e['menu_id'] == item['menu_id']);

    if (index >= 0) {
      _cartItems[index]['quantity'] += 1;
    } else {
      _cartItems.add({
        'menu_id': item['menu_id'],
        'name': item['name'],
        'price': item['price'],
        'image_url': item['image_url'],
        'truck_id': truckId,
        'truck_city': truckCity,
        'quantity': 1,

        // 🆕 Enhanced fields
        'isVegan': item['isVegan'] ?? false,
        'isSpicy': item['isSpicy'] ?? false,
        'calories': item['calories'],
      });
    }

    return true;
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
