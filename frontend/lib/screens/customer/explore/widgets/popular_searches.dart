import 'package:flutter/material.dart';
import 'package:myapp/core/services/truckOwner_service.dart';
import 'package:myapp/screens/customer/explore/widgets/custom_trucks.dart';

class PopularSearchesSection extends StatelessWidget {
  const PopularSearchesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "Popular Searches",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _searchTile(
                context,
                title: "Open Now",
                color: Colors.red,
                fetchTrucks: TruckOwnerService.getOpenNowTrucks,
              ),
              _searchTile(
                context,
                title: "Highest Rated",
                color: Colors.pink,
                fetchTrucks: TruckOwnerService.getHighestRatedTrucks,
              ),
              _searchTile(
                context,
                title: "Featured",
                color: Colors.deepOrange,
                fetchTrucks: () async {
                  // TODO: implement featured logic or show snackbar
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Coming soon: Featured trucks")),
                  );
                  return [];
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _searchTile(
    BuildContext context, {
    required String title,
    required Color color,
    required Future<List<dynamic>> Function() fetchTrucks,
  }) {
    return GestureDetector(
      onTap: () async {
        try {
          final trucks = await fetchTrucks();
          if (context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CustomTruckListPage(
                  title: title,
                  trucks: trucks,
                ),
              ),
            );
          }
        } catch (e) {
          print("❌ Error loading $title trucks: $e");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to load $title trucks")),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: color.withOpacity(0.85),
        ),
        child: Center(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
