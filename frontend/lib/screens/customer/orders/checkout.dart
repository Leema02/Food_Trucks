import 'package:flutter/material.dart';
import '../cart/cart_controller.dart';
import '../../../core/services/order_service.dart';

class CheckoutPage extends StatefulWidget {
  final String truckId;

  const CheckoutPage({super.key, required this.truckId});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  bool isSubmitting = false;
  String orderType = 'pickup';

  Future<void> _placeOrder() async {
    setState(() => isSubmitting = true);

    final cartItems = CartController.getCartItems();
    final items = cartItems.map((item) {
      return {
        "menu_id": item['menu_id'],
        "name": item['name'],
        "quantity": item['quantity'],
        "price": item['price'],
      };
    }).toList();

    final orderData = {
      "truck_id": widget.truckId,
      "items": items,
      "total_price": CartController.getTotal(),
      "order_type": orderType,
    };

    final response = await OrderService.placeOrder(orderData);
    setState(() => isSubmitting = false);

    if (response.statusCode == 201) {
      CartController.clearCart();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Order placed successfully!")),
        );
        Navigator.pop(context);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Failed: ${response.body}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = CartController.getTotal();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Checkout"),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Choose Order Type:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 10),
            Row(
              children: [
                Radio<String>(
                  value: 'pickup',
                  groupValue: orderType,
                  onChanged: (value) => setState(() => orderType = value!),
                ),
                const Text('Pickup'),
                const SizedBox(width: 20),
                Radio<String>(
                  value: 'delivery',
                  groupValue: orderType,
                  onChanged: (value) => setState(() => orderType = value!),
                ),
                const Text('Delivery'),
              ],
            ),
            const SizedBox(height: 30),
            Text(
              "Total: ₪${total.toStringAsFixed(2)}",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isSubmitting ? null : _placeOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text("Place Order",
                        style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
