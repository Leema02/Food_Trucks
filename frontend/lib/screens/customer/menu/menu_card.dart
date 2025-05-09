import 'package:flutter/material.dart';
import 'package:myapp/screens/customer/cart/cart_controller.dart';

class MenuCard extends StatelessWidget {
  final Map<String, dynamic> item;

  const MenuCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final String? imageUrl = item['image_url'] != null
        ? (item['image_url'].toString().startsWith('http')
            ? item['image_url']
            : 'http://192.168.10.7:5000${item['image_url']}')
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: Row(
        children: [
          // 🍔 Menu Image
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
          const SizedBox(width: 14),

          // 📝 Info Section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'] ?? 'Unnamed',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
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
                    color: Colors.black87,
                  ),
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
              });

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${item['name']} added to cart 🛒'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              minimumSize: const Size(60, 35),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('+ Add', style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
