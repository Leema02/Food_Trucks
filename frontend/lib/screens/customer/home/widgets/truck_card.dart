import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:myapp/screens/customer/truck_profile/truck_profile_screen.dart';

const Color ffPrimaryColor = Color(0xFFFF6B35);
const Color ffAccentColor = Color(0xFFFFD166);
const Color ffSuccessColor = Color(0xFF2E7D32);
const Color ffErrorColor = Color(0xFFC62828);

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
      final open = DateFormat("hh:mm a").parse(openTimeStr);
      final close = DateFormat("hh:mm a").parse(closeTimeStr);

      final openTime =
          DateTime(now.year, now.month, now.day, open.hour, open.minute);
      DateTime closeTime =
          DateTime(now.year, now.month, now.day, close.hour, close.minute);

      if (closeTime.isBefore(openTime)) {
        closeTime = closeTime.add(const Duration(days: 1));
      }

      final isOpen = now.isAfter(openTime) && now.isBefore(closeTime);
      return _buildStatusPill(isOpen: isOpen);
    } catch (e) {
      return const SizedBox.shrink();
    }
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: ffPaddingSm, vertical: 6),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 132, 0).withOpacity(0.7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: ffPaddingSm),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
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

    return SizedBox(
      height: 240,
      child: Card(
        margin: const EdgeInsets.symmetric(
            horizontal: ffPaddingMd, vertical: ffPaddingSm),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ffBorderRadius),
        ),
        clipBehavior: Clip.antiAlias,
        elevation: 4,
        child: InkWell(
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
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background image
              CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey.shade200,
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: ffPrimaryColor,
                      strokeWidth: 2.5,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey.shade100,
                  child: Icon(
                    Icons.no_food_rounded,
                    color: Colors.grey.shade400,
                    size: 48,
                  ),
                ),
              ),

              // Gradient overlay
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.1),
                      Colors.black.withOpacity(0.5),
                    ],
                  ),
                ),
              ),

              // Status and rating badges
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          color: ffAccentColor, size: 16),
                      const SizedBox(width: ffPaddingSm),
                      Text(
                        reviewCount > 0
                            ? averageRating!.toStringAsFixed(1)
                            : 'New',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Truck info at bottom
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(ffPaddingMd),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        truck['truck_name'] ?? 'Unnamed Truck',
                        style: const TextStyle(
                          color: Color.fromARGB(255, 255, 255, 255),
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                          shadows: [
                            Shadow(
                              blurRadius: 6,
                              color: Colors.black,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: ffPaddingSm),
                      Wrap(
                        spacing: ffPaddingSm,
                        children: [
                          _buildInfoChip(
                            Icons.location_on_outlined,
                            truck['city'] ?? 'Unknown City',
                          ),
                          _buildInfoChip(
                            Icons.restaurant_menu_rounded,
                            truck['cuisine_type'] ?? 'N/A',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
