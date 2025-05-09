import 'package:flutter/material.dart';
import 'package:myapp/screens/customer/cart/cart_controller.dart';

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

  @override
  Widget build(BuildContext context) {
    final total = CartController.getTotal();

    return Scaffold(
      appBar: AppBar(title: const Text('My Cart')),
      body: cart.isEmpty
          ? const Center(child: Text('🛒 Your cart is empty.'))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cart.length,
                    itemBuilder: (context, index) {
                      final item = cart[index];
                      return ListTile(
                        leading: item['image_url'] != null
                            ? Image.network(item['image_url'], width: 50)
                            : const Icon(Icons.fastfood),
                        title: Text(item['name']),
                        subtitle:
                            Text('\$${item['price']} × ${item['quantity']}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () => updateQuantity(index, -1),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () => updateQuantity(index, 1),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
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
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          // TODO: Handle order logic
                        },
                        child: const Text('Checkout'),
                      )
                    ],
                  ),
                )
              ],
            ),
    );
  }
}
