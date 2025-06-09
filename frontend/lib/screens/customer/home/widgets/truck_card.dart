import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart'; // Ensure you have this
import 'package:myapp/screens/customer/menu/truck_menu.dart';
// NEW: Import the TruckProfileScreen
import 'package:myapp/screens/customer/truck_profile/truck_profile_screen.dart'; // Adjust path

// Styles for TruckCard (Foodie Fleet Theme)
const Color ffPrimaryColorCard = Colors.orange;
const Color ffSurfaceColorCard = Colors.white;
const Color ffOnSurfaceColorCard = Colors.black87;
const Color ffSecondaryTextColorCard = Colors.black54;
const Color ffAccentColorCard = Colors.amber; // For stars
const double ffPaddingSmCard = 8.0;
const double ffPaddingMdCard = 12.0;
const double ffBorderRadiusCard = 16.0; // Slightly less roundness than premium slider card


class TruckCard extends StatelessWidget {
  final dynamic truck;
  final List<String> activeSearchTerms;

  const TruckCard({
    super.key,
    required this.truck,
    required this.activeSearchTerms,
  });

  @override
  Widget build(BuildContext context) {
    final String? imagePath = truck['logo_image_url'] as String?;
    final String? imageUrl = imagePath != null
        ? (imagePath.startsWith('http')
        ? imagePath
        : 'http://10.0.2.2:5000$imagePath') // Ensure this IP is correct for your emulator/device
        : null; // No placeholder string here, let CachedNetworkImage handle it

    // Safely parse average_rating and review_count
    final double? averageRating = (truck['average_rating'] as num?)?.toDouble();
    final int reviewCount = truck['review_count'] as int? ?? 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Adjusted vertical margin
      decoration: BoxDecoration(
        color: ffSurfaceColorCard,
        borderRadius: BorderRadius.circular(ffBorderRadiusCard),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(ffBorderRadiusCard)),
            child: CachedNetworkImage(
                imageUrl: imageUrl ?? 'https://via.placeholder.com/800x400.png?text=${truck['truck_name'] ?? 'Food Truck'}', // Fallback placeholder
                height: 170, // Slightly adjusted
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                    height: 170,
                    color: Colors.grey.shade200,
                    child: const Center(child: CircularProgressIndicator(color: ffPrimaryColorCard, strokeWidth: 2.5))),
                errorWidget: (context, url, error) => Container(
                    height: 170,
                    color: Colors.grey.shade100,
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.broken_image_outlined, color: Colors.grey.shade400, size: 48),
                      const SizedBox(height: ffPaddingSmCard),
                      Text("No Image", style: TextStyle(color: Colors.grey.shade500)),
                    ]))),
          ),
          Padding(
            padding: const EdgeInsets.all(ffPaddingMdCard),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  truck['truck_name'] ?? 'Unnamed Truck',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold, color: ffOnSurfaceColorCard, fontSize: 19),
                ),
                const SizedBox(height: ffPaddingSmCard / 2),
                Text(
                  truck['cuisine_type'] ?? 'Cuisine not specified',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: ffSecondaryTextColorCard),
                ),
                const SizedBox(height: ffPaddingSmCard),
                Row(
                  children: [
                    Icon(Icons.star_rounded, color: ffAccentColorCard, size: 20),
                    const SizedBox(width: 4),
                    if (averageRating != null && reviewCount > 0)
                      Row(
                        children: [
                          Text(
                            averageRating.toStringAsFixed(1),
                            style: const TextStyle(fontWeight: FontWeight.w600, color: ffOnSurfaceColorCard, fontSize: 14),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '($reviewCount Reviews)',
                            style: const TextStyle(fontSize: 13, color: ffSecondaryTextColorCard),
                          ),
                        ],
                      )
                    else
                      const Text(
                        'New',
                        style: TextStyle(fontWeight: FontWeight.w600, color: ffPrimaryColorCard, fontSize: 14),
                      ),
                  ],
                ),
                const SizedBox(height: ffPaddingSmCard),
                Text(
                  'Hours: ${truck['operating_hours']?['open'] ?? '--'} - ${truck['operating_hours']?['close'] ?? '--'}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: ffSecondaryTextColorCard),
                ),
                const SizedBox(height: ffPaddingMdCard + 4), // Increased space before buttons
                Row( // Row for two buttons
                  mainAxisAlignment: MainAxisAlignment.end, // Align buttons to the right
                  children: [
                    // --- NEW: View Profile Button ---
                    OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TruckProfileScreen(truckId: truck['_id'] as String,initialAverageRating: averageRating,
                              initialReviewCount: reviewCount,),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: ffPrimaryColorCard,
                        side: const BorderSide(color: ffPrimaryColorCard, width: 1.5),
                        padding: const EdgeInsets.symmetric(horizontal: ffPaddingMdCard, vertical: ffPaddingSmCard + 2), // 10
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(ffBorderRadiusCard - 4), // 8
                        ),
                      ),
                      child: const Text('View Profile', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(width: ffPaddingSmCard), // Space between buttons

                    // Existing View Menu Button
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TruckMenuPage(
                              truckId: truck['_id'],
                              truckCity: truck['city'],
                              activeSearchTerms: activeSearchTerms,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ffPrimaryColorCard,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: ffPaddingMdCard, vertical: ffPaddingSmCard + 2), // 10
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(ffBorderRadiusCard - 4), // 8
                        ),
                      ),
                      child: const Text('View Menu', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}