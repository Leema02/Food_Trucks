import 'package:flutter/material.dart';
import 'package:myapp/screens/customer/checkout/payment_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../cart/cart_controller.dart';
import '../../../core/services/order_service.dart';

class CheckoutPage extends StatefulWidget {
  final String truckId;
  final String truckCity;
  final String customerCity;

  const CheckoutPage({
    super.key,
    required this.truckId,
    required this.truckCity,
    required this.customerCity,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  bool isSubmitting = false;
  String orderType = 'pickup';
  String deliveryAddress = '';

  @override
  void initState() {
    super.initState();

    // force pickup if cities don’t match
    if (!_citiesMatch()) {
      orderType = 'pickup';
    }
  }

  bool _citiesMatch() {
    return widget.customerCity.trim().toLowerCase() ==
        widget.truckCity.trim().toLowerCase();
  }

  Future<void> _placeOrder() async {
    if (!_citiesMatch()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("❌ You can only order from trucks in your city.")),
      );
      return;
    }

    if (orderType == 'delivery' && deliveryAddress.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❗ Delivery address is required.")),
      );
      return;
    }

    setState(() => isSubmitting = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('user_email') ?? 'guest@example.com';

      final cartItems = CartController.getCartItems();
      final totalNIS = CartController.getTotal();
      final totalAgorot =
          (totalNIS * 100).round(); // Convert to agorot for Stripe

      final items = cartItems.map((item) {
        return {
          "menu_id": item['menu_id'],
          "name": item['name'],
          "quantity": item['quantity'],
          "price": item['price'],
        };
      }).toList();

      // Step 1: Stripe payment
      final success = await PaymentService.pay(
        context,
        totalAgorot,
        {
          "truckId": widget.truckId,
          "userEmail": email,
        },
      );

      if (!success) {
        setState(() => isSubmitting = false);
        return;
      }

      // Step 2: Submit order to backend
      final orderData = {
        "truck_id": widget.truckId,
        "items": items,
        "total_price": totalNIS,
        "order_type": orderType,
        if (orderType == 'delivery') "delivery_address": deliveryAddress.trim(),
        "payment_status": "paid"
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
    } catch (e) {
      setState(() => isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = CartController.getTotal();
    final citiesMatch = _citiesMatch();

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
                  onChanged: (value) {
                    setState(() => orderType = value!);
                  },
                ),
                const Text('Pickup'),
                const SizedBox(width: 20),
                Radio<String>(
                  value: 'delivery',
                  groupValue: orderType,
                  onChanged: citiesMatch
                      ? (value) => setState(() => orderType = value!)
                      : null,
                ),
                const Text('Delivery'),
              ],
            ),
            if (!citiesMatch)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  "⚠ Delivery is only available for trucks in your city.",
                  style: TextStyle(color: Colors.red, fontSize: 13),
                ),
              ),
            if (orderType == 'delivery')
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: TextField(
                  onChanged: (value) => deliveryAddress = value,
                  decoration: const InputDecoration(
                    labelText: 'Delivery Address',
                    border: OutlineInputBorder(),
                  ),
                ),
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
