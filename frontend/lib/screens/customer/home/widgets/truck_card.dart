import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:myapp/screens/customer/menu/truck_menu.dart';
import 'package:myapp/screens/customer/truck_profile/truck_profile_screen.dart';

const Color ffPrimaryColor = Color(0xFFFF6B35);
const Color ffSurfaceColor = Colors.white;
const Color ffOnSurfaceColor = Color(0xFF2D2D2D);
const Color ffSecondaryTextColor = Color(0xFF6C757D);
const Color ffAccentColor = Color(0xFFFFD166);
const Color ffSuccessColor = Color(0xFF2E7D32);
const Color ffErrorColor = Color(0xFFC62828);

const double ffPaddingXs = 4.0;
const double ffPaddingSm = 8.0;
const double ffPaddingMd = 16.0;
const double ffBorderRadius = 18.0;

class TruckCard extends StatelessWidget {
  final dynamic truck;
  final List<String> activeSearchTerms;

  const TruckCard({
    super.key,
    required this.truck,
    required this.activeSearchTerms,
  });

  Widget _buildStatusPill({required bool isOpen}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isOpen ? ffSuccessColor : ffErrorColor,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(
        isOpen ? "Open" : "Closed",
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _getTruckStatus(String? openTimeStr, String? closeTimeStr) {
    if (openTimeStr == null || closeTimeStr == null) {
      return const SizedBox.shrink();
    }
    try {
      final now = DateTime.now();
      final openTime = DateFormat("hh:mm a").parse(openTimeStr);
      final closeTime = DateFormat("hh:mm a").parse(closeTimeStr);

      final todayOpen = DateTime(now.year, now.month, now.day, openTime.hour, openTime.minute);
      final todayClose = DateTime(now.year, now.month, now.day, closeTime.hour, closeTime.minute);

      final bool isOpen = now.isAfter(todayOpen) && now.isBefore(todayClose);

      return _buildStatusPill(isOpen: isOpen);
    } catch (e) {
      return const SizedBox.shrink();
    }
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: ffPaddingSm, vertical: ffPaddingXs + 2),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: ffSecondaryTextColor, size: 16),
          const SizedBox(width: ffPaddingSm),
          Text(
            text,
            style: const TextStyle(
              color: ffSecondaryTextColor,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final String? imagePath = truck['logo_image_url'] as String?;
    final String imageUrl = imagePath != null && imagePath.isNotEmpty
        ? (imagePath.startsWith('http')
        ? imagePath
        : 'http://10.0.2.2:5000$imagePath')
        : 'https://via.placeholder.com/800x400.png?text=${Uri.encodeComponent(truck['truck_name'] ?? 'Food Truck')}';

    final double? averageRating = (truck['average_rating'] as num?)?.toDouble();
    final int reviewCount = truck['review_count'] as int? ?? 0;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TruckProfileScreen(
              truckId: truck['_id'] as String,
              initialAverageRating: averageRating,
              initialReviewCount: reviewCount,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: ffPaddingMd, vertical: ffPaddingSm),
        decoration: BoxDecoration(
          color: ffSurfaceColor,
          borderRadius: BorderRadius.circular(ffBorderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(ffBorderRadius)),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                        height: 180,
                        color: Colors.grey.shade200,
                        child: const Center(child: CircularProgressIndicator(color: ffPrimaryColor, strokeWidth: 2.5))),
                    errorWidget: (context, url, error) => Container(
                      height: 180,
                      color: Colors.grey.shade100,
                      child: Icon(Icons.no_food_rounded, color: Colors.grey.shade400, size: 48),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(ffBorderRadius)),
                      gradient: LinearGradient(
                        colors: [Colors.black.withOpacity(0.5), Colors.transparent, Colors.black.withOpacity(0.6)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.0, 0.6, 1.0],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: ffPaddingMd,
                  left: ffPaddingMd,
                  child: _getTruckStatus(
                    truck['operating_hours']?['open'],
                    truck['operating_hours']?['close'],
                  ),
                ),
                Positioned(
                  top: ffPaddingMd,
                  right: ffPaddingMd,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star_rounded, color: ffAccentColor, size: 16),
                        const SizedBox(width: ffPaddingSm),
                        Text(
                          reviewCount > 0 ? averageRating!.toStringAsFixed(1) : 'New',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900 ,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(ffPaddingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    truck['truck_name'] ?? 'Unnamed Truck',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: ffOnSurfaceColor,
                      fontSize: 20,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: ffPaddingSm),

                  Row(
                    children: [
                      _buildInfoChip(Icons.location_on_outlined, truck['city'] ?? 'Unknown City'),
                      const SizedBox(width: ffPaddingSm),
                      _buildInfoChip(Icons.restaurant_menu_rounded, truck['cuisine_type'] ?? 'N/A'),
                    ],
                  ),
                  const SizedBox(height: 2),

                  // SizedBox(
                  //   width: double.infinity,
                  //   child: ElevatedButton.icon(
                  //     onPressed: () {
                  //       Navigator.push(
                  //         context,
                  //         MaterialPageRoute(
                  //           builder: (_) => TruckMenuPage(
                  //             truckId: truck['_id'],
                  //             truckCity: truck['city'],
                  //             activeSearchTerms: activeSearchTerms,
                  //           ),
                  //         ),
                  //       );
                  //     },
                  //     icon: const Icon(Icons.menu_book_rounded),
                  //     label: const Text('View Menu', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  //     style: ElevatedButton.styleFrom(
                  //       backgroundColor: ffPrimaryColor,
                  //       foregroundColor: Colors.white,
                  //       padding: const EdgeInsets.symmetric(vertical: ffPaddingMd - 2),
                  //       shape: RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.circular(12),
                  //       ),
                  //       elevation: 2,
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}