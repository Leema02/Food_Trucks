import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:myapp/screens/customer/cart/cart_controller.dart'; // Adjust path

// Import ReviewService - ENSURE THIS PATH IS CORRECT
import '../../../../core/services/review_service.dart'; // Adjust path to your ReviewService

// --- Styling Constants (from YOUR card code) ---
const Color ffPrimaryColor = Color(0xFFFF9F1C);
const Color ffAccentColor = Color(0xFFFFD166);
const Color ffSurfaceColor = Color(0xFFFDFDFD);
const Color ffOnSurfaceColor = Color(0xFF2D2D2D);
const Color ffSecondaryTextColor = Color(0xFF7A7A7A);
// const Color ffSubtleTextColor = Color(0xFFB0B0B0); // Not used in your rating display
const Color ffShadowColor = Color(0x1A000000);

const double ffCardBorderRadius = 24.0;
const double ffImageHeight = 120.0; // As per your code
// const double ffCardWidthFactor = 0.7; // Your card uses fixed width 230.0

const double ffPaddingXs = 4.0;
const double ffPaddingSm = 8.0;
const double ffPaddingMd = 16.0;
// const double ffPaddingLg = 20.0;

// CHANGED RecommendationCard to StatefulWidget
class RecommendationCard extends StatefulWidget {
  final Map<String, dynamic> menuItem;
  final String truckName;

  const RecommendationCard({
    super.key,
    required this.menuItem,
    required this.truckName,
  });

  @override
  State<RecommendationCard> createState() => _RecommendationCardState();
}

class _RecommendationCardState extends State<RecommendationCard> {
  double _averageRating = 0.0;
  int _reviewCount = 0;
  bool _isLoadingReviews = true;

  @override
  void initState() {
    super.initState();
    _fetchThisItemReviews();
  }

  Future<void> _fetchThisItemReviews() async {
    if (!mounted) return;
    // No need to set _isLoadingReviews to true here again, already true by default or set by parent

    final String? menuItemId = widget.menuItem['_id'] as String?;
    if (menuItemId == null) {
      print(
          "RecommendationCard: MenuItem ID is null for ${widget.menuItem['name']}, cannot fetch reviews.");
      if (mounted) {
        setState(() => _isLoadingReviews = false);
      }
      return;
    }

    print(
        "[CARD_REVIEW_DEBUG] Fetching reviews for item: ${widget.menuItem['name']} (ID: $menuItemId)");

    try {
      // Ensure ReviewService.fetchMenuItemReviews is a static method
      final reviews = await ReviewService.fetchMenuItemReviews2(menuItemId);
      if (!mounted) return;

      if (reviews.isNotEmpty) {
        double totalRating = 0;
        for (var review in reviews) {
          if (review is Map<String, dynamic> && review['rating'] is num) {
            totalRating += (review['rating'] as num).toDouble();
          }
        }
        setState(() {
          _reviewCount = reviews.length;
          _averageRating = totalRating /
              _reviewCount; // Avoid division by zero if count somehow becomes 0 after check
          _isLoadingReviews = false;
        });
        print(
            "[CARD_REVIEW_DEBUG] Reviews for ${widget.menuItem['name']}: Avg $_averageRating, Count $_reviewCount");
      } else {
        setState(() {
          // No reviews found
          _reviewCount = 0;
          _averageRating = 0.0;
          _isLoadingReviews = false;
        });
        print(
            "[CARD_REVIEW_DEBUG] No reviews found for ${widget.menuItem['name']}");
      }
    } catch (e) {
      print(
          "[CARD_REVIEW_DEBUG] Error fetching reviews in card for item $menuItemId: $e");
      if (mounted) {
        setState(() {
          _isLoadingReviews = false;
          _reviewCount = 0; // Reset on error
          _averageRating = 0.0;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Accessing widget.menuItem and widget.truckName
    final String? imageUrl = widget.menuItem['image_url'] as String?;
    final String placeholderImage =
        'https://via.placeholder.com/400x250.png?text=Food+Image';

    final Map<String, dynamic> itemDetailsForCart = {
      'menu_id': widget.menuItem['_id'],
      'name': widget.menuItem['name'],
      'price': widget.menuItem['price'],
      'image_url': widget.menuItem['image_url'],
      'truck_id': widget.menuItem['truck_id_for_recommendation'],
      'truck_city': widget.menuItem['truck_city_for_recommendation'],
      'isVegan': widget.menuItem['isVegan'] ?? false,
      'isSpicy': widget.menuItem['isSpicy'] ?? false,
      'calories': widget.menuItem['calories'],
    };

    final bool isVegan = widget.menuItem['isVegan'] as bool? ?? false;
    final bool isSpicy = widget.menuItem['isSpicy'] as bool? ?? false;

    return Container(
      width: 230.0, // Your specified width
      margin: const EdgeInsets.only(
          right: ffPaddingMd, bottom: 25.0), // Your specified margin
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
              // mainAxisSize: MainAxisSize.min, // Keep this if it helps your layout
              children: [
                // --- Premium Image Section --- (YOUR EXISTING IMAGE STACK)
                Stack(
                  children: [
                    SizedBox(
                      height: ffImageHeight,
                      width: double.infinity,
                      child: CachedNetworkImage(
                        imageUrl:
                            (imageUrl != null && imageUrl.startsWith('http'))
                                ? imageUrl
                                : (imageUrl != null
                                    ? 'http://10.0.2.2:5000$imageUrl'
                                    : placeholderImage),
                        fit: BoxFit.cover,
                        placeholder: (context, url) => ShimmerPlaceholder(
                            height: ffImageHeight), // Pass height
                        errorWidget: (context, url, error) =>
                            ImageErrorPlaceholder(
                                height: ffImageHeight), // Pass height
                      ),
                    ),
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
                    if (isVegan || isSpicy)
                      Positioned(
                        top: ffPaddingMd,
                        right: ffPaddingMd,
                        child: Wrap(
                          spacing: ffPaddingXs,
                          children: [
                            if (isVegan)
                              _buildPremiumTag(
                                  "Vegan", Icons.eco, Colors.green),
                            if (isSpicy)
                              _buildPremiumTag("Spicy",
                                  Icons.local_fire_department, Colors.red),
                          ],
                        ),
                      ),
                    Positioned(
                      left: ffPaddingMd,
                      bottom: ffPaddingMd,
                      child: Text(
                        widget.truckName, // Use widget.truckName
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

                // --- Details Section --- (YOUR EXISTING DETAILS PADDING AND COLUMN)
                Padding(
                  padding: const EdgeInsets.all(ffPaddingMd),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize
                        .min, // Add this to help content fit if not already there
                    children: [
                      Text(
                        widget.menuItem['name'] as String? ?? 'Premium Dish',
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
                      Row(
                        children: [
                          Icon(Icons.fastfood_outlined,
                              size: 16, color: ffSecondaryTextColor),
                          const SizedBox(width: ffPaddingXs),
                          Text(
                            '${widget.menuItem['calories']?.toString() ?? 'N/A'} Cal',
                            style: const TextStyle(
                              // Used const for your original style
                              color: ffSecondaryTextColor,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: ffPaddingMd),

                          // =========== MODIFIED RATING DISPLAY START ===========
                          if (_isLoadingReviews)
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 1.5, color: ffAccentColor),
                            )
                          else if (_reviewCount > 0) ...[
                            const Icon(Icons.star,
                                size: 16, color: ffAccentColor), // Filled star
                            const SizedBox(width: ffPaddingXs),
                            Text(
                              '${_averageRating.toStringAsFixed(1)} ($_reviewCount)',
                              style: const TextStyle(
                                // Used const for your original style
                                color: ffSecondaryTextColor,
                                fontSize: 12,
                              ),
                            ),
                          ] else ...[
                            // If no reviews, display as per your original placeholder but with an empty star
                            Icon(Icons.star,
                                size: 16,
                                color: ffSecondaryTextColor
                                    .withOpacity(0.6)), // Empty/Outline star
                            const SizedBox(width: ffPaddingXs),
                            const Text(
                              'New', // Or 'No Reviews' or '0 (0)'
                              style: TextStyle(
                                color: ffSecondaryTextColor,
                                fontSize: 12,
                              ),
                            ),
                          ],
                          // =========== MODIFIED RATING DISPLAY END ===========
                        ],
                      ),
                      const SizedBox(height: 10.0), // Your original spacing
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment
                            .center, // Added for vertical alignment
                        children: [
                          Text(
                            '\$${(widget.menuItem['price'] as num?)?.toStringAsFixed(2) ?? 'N/A'}',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  color: ffPrimaryColor,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 20,
                                ),
                          ),
                          FloatingActionButton.small(
                            onPressed: () =>
                                _addToCart(context, itemDetailsForCart),
                            backgroundColor: ffPrimaryColor,
                            foregroundColor: Colors.white,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            child: const Icon(Icons.add_shopping_cart_outlined,
                                size: 20), // Your original icon
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              // YOUR EXISTING PREMIUM CORNER DECORATION
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

  // YOUR EXISTING HELPER METHODS
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
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: Colors.white),
        const SizedBox(width: ffPaddingXs),
        Text(
          text,
          style: const TextStyle(
              color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ]),
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

// YOUR EXISTING PLACEHOLDER WIDGETS
class ShimmerPlaceholder extends StatelessWidget {
  final double height; // Added required height
  const ShimmerPlaceholder({super.key, required this.height});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: height, // Use passed height
      width: double.infinity,
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
      // child: const Center(child: Icon(Iconsax.gallery, size: 40, color: Colors.grey)),
    );
  }
}

class ImageErrorPlaceholder extends StatelessWidget {
  final double height;
  const ImageErrorPlaceholder(
      {super.key, required this.height}); // Added required height
  @override
  Widget build(BuildContext context) {
    return Container(
      height: height, // Use passed height
      width: double.infinity,
      color: Colors.grey.shade100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.abc, size: 40, color: Colors.grey.shade400),
          const SizedBox(height: ffPaddingSm),
          Text("Image N/A",
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
        ],
      ),
    );
  }
}
