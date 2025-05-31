import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:myapp/screens/customer/cart/cart_controller.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

// --- Premium Styling for "Foodie Fleet" Card ---
const Color ffPrimaryColor = Color(0xFFFF9F1C); // Vibrant orange
const Color ffAccentColor = Color(0xFFFFD166); // Soft amber
const Color ffSurfaceColor = Color(0xFFFDFDFD); // Off-white background
const Color ffOnSurfaceColor = Color(0xFF2D2D2D); // Dark text
const Color ffSecondaryTextColor = Color(0xFF7A7A7A); // Medium grey
const Color ffSubtleTextColor = Color(0xFFB0B0B0); // Light grey
const Color ffShadowColor = Color(0x1A000000); // Soft black shadow

// Card dimensions
const double ffCardBorderRadius = 24.0;
const double ffImageHeight = 160.0;
const double ffCardWidthFactor = 0.7;

// Spacing
const double ffPaddingXs = 4.0;
const double ffPaddingSm = 8.0;
const double ffPaddingMd = 16.0;
const double ffPaddingLg = 20.0;

class RecommendationCard extends StatelessWidget {
  final Map<String, dynamic> menuItem;
  final String truckName;

  const RecommendationCard({
    super.key,
    required this.menuItem,
    required this.truckName,
  });

  @override
  Widget build(BuildContext context) {
    final String? imageUrl = menuItem['image_url'] as String?;
    final String placeholderImage = 'https://via.placeholder.com/400x250.png?text=Food+Image';

    final Map<String, dynamic> itemDetailsForCart = {
      'menu_id': menuItem['_id'],
      'name': menuItem['name'],
      'price': menuItem['price'],
      'image_url': menuItem['image_url'],
      'truck_id': menuItem['truck_id_for_recommendation'],
      'truck_city': menuItem['truck_city_for_recommendation'],
      'isVegan': menuItem['isVegan'] ?? false,
      'isSpicy': menuItem['isSpicy'] ?? false,
      'calories': menuItem['calories'],
    };

    final bool isVegan = menuItem['isVegan'] as bool? ?? false;
    final bool isSpicy = menuItem['isSpicy'] as bool? ?? false;

    return Container(
      width: MediaQuery.of(context).size.width * ffCardWidthFactor,
      margin: const EdgeInsets.only(right: ffPaddingMd, bottom: ffPaddingMd),
      decoration: BoxDecoration(
        color: ffSurfaceColor,
        borderRadius: BorderRadius.circular(ffCardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: ffShadowColor,
            blurRadius: 20,
            spreadRadius: 1,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(ffCardBorderRadius),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Premium Image Section ---
                Stack(
                  children: [
                    // Image with shimmer effect
                    SizedBox(
                      height: ffImageHeight,
                      width: double.infinity,
                      child: CachedNetworkImage(
                        imageUrl: (imageUrl != null && imageUrl.startsWith('http'))
                            ? imageUrl
                            : (imageUrl != null
                            ? 'http://10.0.2.2:5000$imageUrl'
                            : placeholderImage),
                        fit: BoxFit.cover,
                        placeholder: (context, url) => ShimmerPlaceholder(),
                        errorWidget: (context, url, error) => ImageErrorPlaceholder(),
                      ),
                    ),

                    // Gradient overlay
                    Container(
                      height: ffImageHeight,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.6),
                          ],
                        ),
                      ),
                    ),

                    // Vegan/Spicy tags
                    if (isVegan || isSpicy)
                      Positioned(
                        top: ffPaddingMd,
                        right: ffPaddingMd,
                        child: Wrap(
                          spacing: ffPaddingXs,
                          children: [
                            if (isVegan) _buildPremiumTag("Vegan", Icons.eco, Colors.green),
                            if (isSpicy) _buildPremiumTag("Spicy", Icons.local_fire_department, Colors.red),
                          ],
                        ),
                      ),

                    // Truck name at bottom of image
                    Positioned(
                      left: ffPaddingMd,
                      bottom: ffPaddingMd,
                      child: Text(
                        truckName,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ],
                ),

                // --- Details Section ---
                Padding(
                  padding: const EdgeInsets.all(ffPaddingMd),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Dish name with custom font
                      Text(
                        menuItem['name'] as String? ?? 'Premium Dish',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: ffOnSurfaceColor,
                          fontSize: 18,
                          height: 1.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: ffPaddingSm),

                      // Calories and rating row
                      Row(
                        children: [
                          Icon(Icons.fastfood_outlined, size: 16, color: ffSecondaryTextColor),
                          const SizedBox(width: ffPaddingXs),
                          Text(
                            '${menuItem['calories']?.toString() ?? 'N/A'} Cal',
                            style: TextStyle(
                              color: ffSecondaryTextColor,
                              fontSize: 12,
                            ),
                          ),

                          const SizedBox(width: ffPaddingMd),

                          Icon(Iconsax.star, size: 16, color: ffAccentColor),
                          const SizedBox(width: ffPaddingXs),
                          Text(
                            '4.8 (25)',
                            style: TextStyle(
                              color: ffSecondaryTextColor,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: ffPaddingMd),

                      // Price and Add button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '\$${(menuItem['price'] as num?)?.toStringAsFixed(2) ?? 'N/A'}',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: ffPrimaryColor,
                              fontWeight: FontWeight.w800,
                              fontSize: 20,
                            ),
                          ),

                          // Floating action button
                          FloatingActionButton.small(
                            onPressed: () => _addToCart(context, itemDetailsForCart),
                            backgroundColor: ffPrimaryColor,
                            foregroundColor: Colors.white,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Iconsax.add),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Premium corner decoration
            Positioned(
              top: -30,
              right: -30,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: ffPrimaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumTag(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: ffPaddingSm, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: ffPaddingXs),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _addToCart(BuildContext context, Map<String, dynamic> item) {
    bool success = CartController.addToCart(item);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success
            ? "${item['name']} added to cart!"
            : "Cannot add from different truck. Cart has items from ${CartController.activeTruckCity ?? 'another location'}."),
        backgroundColor: success ? Colors.green.shade600 : Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(10),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

// Custom shimmer placeholder widget
class ShimmerPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey.shade200,
            Colors.grey.shade100,
            Colors.grey.shade200,
          ],
          stops: const [0.1, 0.5, 0.9],
        ),
      ),
      child: const Center(
        child: Icon(Iconsax.gallery, size: 40, color: Colors.grey),
      ),
    );
  }
}

// Custom error placeholder widget
class ImageErrorPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.gallery_slash, size: 40, color: Colors.grey.shade400),
          const SizedBox(height: ffPaddingSm),
          Text("Image not available",
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
        ],
      ),
    );
  }
}