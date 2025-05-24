import 'package:flutter/material.dart';
import 'package:myapp/screens/customer/cart/cart_controller.dart';
import 'package:myapp/screens/customer/checkout/checkout.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<Map<String, dynamic>> get cart => CartController.getCartItems();

  void updateQuantity(int index, int change) {
    setState(() {
      final item = cart[index];
      final menuId = item['menu_id'];

      if (change == -1 && item['quantity'] == 1) {
        CartController.removeFromCart(menuId);
      } else {
        cart[index]['quantity'] += change;
      }
    });
  }

  Future<void> handleCheckout() async {
    final cartItems = CartController.getCartItems();
    final truckId = cartItems.isNotEmpty ? cartItems[0]['truck_id'] : null;
    final truckCity = cartItems.isNotEmpty ? cartItems[0]['truck_city'] : null;
    final prefs = await SharedPreferences.getInstance();
    final customerCity = prefs.getString('city') ?? '';

    if (truckId == null || truckCity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cannot proceed: Missing truck info")),
      );
      return;
    }

    if (customerCity.trim().toLowerCase() != truckCity.trim().toLowerCase()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("❌ You can only order from trucks in your city.")),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CheckoutPage(
          truckId: truckId,
          truckCity: truckCity,
          customerCity: customerCity,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = CartController.getTotal();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
        backgroundColor: Colors.orange,
      ),
      body: cart.isEmpty
          ? const Center(child: Text('🛒 Your cart is empty.'))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cart.length,
                    itemBuilder: (context, index) {
                      final item = cart[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: item['image_url'] != null
                                    ? Image.network(
                                        item['image_url'],
                                        width: 70,
                                        height: 70,
                                        fit: BoxFit.cover,
                                      )
                                    : const Icon(Icons.fastfood, size: 50),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item['name'],
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        if (item['isVegan'] == true)
                                          const Padding(
                                            padding: EdgeInsets.only(right: 6),
                                            child: Text('🌱 Vegan',
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.green)),
                                          ),
                                        if (item['isSpicy'] == true)
                                          const Padding(
                                            padding: EdgeInsets.only(right: 6),
                                            child: Text('🌶️ Spicy',
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.red)),
                                          ),
                                        if (item['calories'] != null)
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(right: 6),
                                            child: Text(
                                              '${item['calories']} cal',
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.orange),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '\$${item['price']} × ${item['quantity']}',
                                      style: const TextStyle(fontSize: 15),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon:
                                        const Icon(Icons.remove_circle_outline),
                                    onPressed: () => updateQuantity(index, -1),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline),
                                    onPressed: () => updateQuantity(index, 1),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, -2),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total:',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          Text('\$${total.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: handleCheckout,
                        child: const Text(
                          "Checkout",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
    );
  }
}
