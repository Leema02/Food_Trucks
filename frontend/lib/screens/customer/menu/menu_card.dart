import 'package:flutter/material.dart';
import 'package:myapp/screens/customer/cart/cart_controller.dart';

class MenuCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final String truckId;

  const MenuCard({super.key, required this.item, required this.truckId});

  @override
  Widget build(BuildContext context) {
    final String? imageUrl = item['image_url'] != null
        ? (item['image_url'].toString().startsWith('http')
            ? item['image_url']
            : 'http://10.0.2.2:5000${item['image_url']}')
        : null;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // 🍔 Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: imageUrl != null
                  ? Image.network(
                      imageUrl,
                      height: 90,
                      width: 90,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      height: 90,
                      width: 90,
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.image_not_supported,
                          color: Colors.grey),
                    ),
            ),
            const SizedBox(width: 16),

            // 📄 Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name'] ?? 'Unnamed',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item['description'] ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "₪${item['price']}",
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87),
                  ),
                ],
              ),
            ),

            // ➕ Add to Cart Button
            ElevatedButton(
              onPressed: () {
                CartController.addToCart({
                  'menu_id': item['_id'],
                  'name': item['name'],
                  'price': item['price'],
                  'image_url': item['image_url'],
                  'truck_id': truckId, // ✅ include truck_id
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${item['name']} added to cart 🛒'),
                    duration: const Duration(seconds: 1),
                    behavior: SnackBarBehavior.floating,
                    margin: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 60),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                minimumSize: const Size(60, 35),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('+ Add',
                  style: TextStyle(fontSize: 13, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
