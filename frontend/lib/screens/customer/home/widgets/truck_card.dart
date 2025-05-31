import 'package:flutter/material.dart';
import 'package:myapp/screens/customer/menu/truck_menu.dart';

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
    final String? imagePath = truck['logo_image_url'];
    final String? imageUrl = imagePath != null
        ? (imagePath.startsWith('http')
            ? imagePath
            : 'http://10.0.2.2:5000$imagePath')
        : null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🖼️ Image or fallback
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: imageUrl != null
                ? Image.network(
                    imageUrl,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                : Container(
                    height: 180,
                    width: double.infinity,
                    color: Colors.grey.shade300,
                    child: const Icon(
                      Icons.image_not_supported,
                      size: 60,
                      color: Colors.grey,
                    ),
                  ),
          ),

          // 🧾 Truck Info
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  truck['truck_name'] ?? 'No Name',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  truck['cuisine_type'] ?? 'Cuisine not specified',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 6),

                // ⭐ Average Rating (if available)
                if (truck.containsKey('average_rating') &&
                    truck['average_rating'] != null)
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        double.tryParse(truck['average_rating'].toString())
                                ?.toStringAsFixed(1) ??
                            '0.0',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 6),
                Text(
                  'Open: ${truck['operating_hours']?['open'] ?? '--'} - ${truck['operating_hours']?['close'] ?? '--'}',
                  style: const TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
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
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('View Menu'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
