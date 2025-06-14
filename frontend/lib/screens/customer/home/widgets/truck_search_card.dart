import 'package:flutter/material.dart';
import 'package:myapp/screens/customer/truck_profile/truck_profile_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

const String baseUrl = 'http://10.0.2.2:5000';

class TruckSearchCard extends StatelessWidget {
  final Map<String, dynamic> truck;

  const TruckSearchCard({Key? key, required this.truck}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String? logoPath = truck['logo_image_url'] as String?;
    final String logoUrl = logoPath != null && logoPath.isNotEmpty
        ? (logoPath.startsWith('http') ? logoPath : '$baseUrl$logoPath')
        : '';

    final double? averageRating = (truck['average_rating'] as num?)?.toDouble();
    final int reviewCount = truck['review_count'] as int? ?? 0;

    return Container(
      height: 131,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
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
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange, width: 2.0),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      imageUrl: logoUrl,
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
                        child: const Icon(Icons.local_shipping_rounded,
                            size: 36,
                            color: Colors.grey),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: SizedBox(
                    height: 80,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              truck['truck_name'] ?? 'Unnamed Truck',
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
                              truck['cuisine_type'] ?? 'No cuisine specified',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
                                fontStyle: FontStyle.italic,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.location_on_rounded,
                                    size: 18,
                                    color: Colors.orange[700]),
                                const SizedBox(width: 4),
                                Text(
                                  truck['city'] ?? 'Unknown City',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),

                            Row(
                              children: [
                                Icon(Icons.star_rounded,
                                    size: 18,
                                    color: Colors.orange[700]),
                                const SizedBox(width: 4),
                                Text(
                                  averageRating?.toStringAsFixed(1) ?? '0.0',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.grey[800],
                                  ),
                                ),
                                Text(
                                  ' (${reviewCount.toString()})',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.orange,
                  ),
                  child: const Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
