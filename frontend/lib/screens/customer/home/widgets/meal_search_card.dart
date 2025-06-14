import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../cart/cart_controller.dart';

const String baseUrl = 'http://10.0.2.2:5000';

class MealSearchCard extends StatelessWidget {
  final Map<String, dynamic> meal;

  const MealSearchCard({super.key, required this.meal});

  @override
  Widget build(BuildContext context) {
    final String? imagePath = meal['image_url'] as String?;
    final String imageUrl = imagePath != null && imagePath.isNotEmpty
        ? (imagePath.startsWith('http') ? imagePath : '$baseUrl$imagePath')
        : '';

    void handleAddToCart() {
      final cartItem = {
        'menu_id': meal['_id'],
        'name': meal['name'],
        'price': meal['price'],
        'image_url': meal['image_url'],
        'truck_id': meal['truck_id'],
        'truck_city': meal['truck_city'],
        'isVegan': meal['isVegan'] ?? false,
        'isSpicy': meal['isSpicy'] ?? false,
        'calories': meal['calories'],
      };

      final success = CartController.addToCart(cartItem);

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${meal['name']} added to cart!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('You can only order from one truck at a time.'),
            backgroundColor: Colors.red[800],
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }

    return Container(
      height: 131,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 3,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.orange,
                    width: 2.5,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[100],
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.orange[300],
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.fastfood,
                          size: 36, color: Colors.grey),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SizedBox(
                  height: 100,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            meal['name'] ?? 'Unnamed Meal',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'From: ${meal['truck_name'] ?? 'Unknown Truck'}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (meal['calories'] != null)
                            Row(
                              children: [
                                Icon(Icons.local_fire_department,
                                    size: 16, color: Colors.orange[700]),
                                const SizedBox(width: 4),
                                Text(
                                  '${meal['calories']} calories',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              if (meal['isVegan'] == true)
                                _buildBadge('VEGAN', Colors.green[800]!,
                                    Colors.green[50]!),
                              if (meal['isSpicy'] == true)
                                _buildBadge(
                                    'SPICY', Colors.red[800]!, Colors.red[50]!),
                            ],
                          ),
                          Text(
                            '\$${meal['price']?.toStringAsFixed(2) ?? 'N/A'}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.orange,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2))
                    ]),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.add_shopping_cart_outlined,
                      color: Colors.white, size: 22),
                  onPressed: handleAddToCart,
                  tooltip: 'Add to Cart',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      margin: const EdgeInsets.only(right: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }
}
