import 'package:flutter/material.dart';
import 'package:myapp/screens/customer/explore/widgets/custom_trucks.dart';
import 'package:myapp/core/services/truckOwner_service.dart';

class PopularSearchesSection extends StatelessWidget {
  const PopularSearchesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final tiles = [
      _PopularSearchTileData(
        title: "Open Now",
        imagePath: "assets/image/explore/open.jpg",
        fetchTrucks: TruckOwnerService.getOpenNowTrucks,
      ),
      _PopularSearchTileData(
        title: "Highest Rated",
        imagePath: "assets/image/explore/rate.jpg",
        fetchTrucks: TruckOwnerService.getHighestRatedTrucks,
      ),
    ];

    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth < 600 ? 2 : 3;

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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            itemCount: tiles.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemBuilder: (context, index) {
              final tile = tiles[index];
              return _buildTile(context, tile);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTile(BuildContext context, _PopularSearchTileData tile) {
    return GestureDetector(
      onTap: () async {
        try {
          final trucks = await tile.fetchTrucks();
          if (context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CustomTruckListPage(
                  title: tile.title,
                  trucks: trucks,
                ),
              ),
            );
          }
        } catch (e) {
          print("❌ Error loading ${tile.title} trucks: $e");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to load ${tile.title} trucks")),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(
            image: AssetImage(tile.imagePath),
            fit: BoxFit.cover,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.black.withOpacity(0.35),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _getIconForTitle(tile.title),
                    color: Colors.white,
                    size: 28,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    tile.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      shadows: [Shadow(blurRadius: 4, color: Colors.black)],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForTitle(String title) {
    switch (title.toLowerCase()) {
      case 'open now':
        return Icons.access_time_filled;
      case 'highest rated':
        return Icons.star_rate;
      default:
        return Icons.search;
    }
  }
}

class _PopularSearchTileData {
  final String title;
  final String imagePath;
  final Future<List<dynamic>> Function() fetchTrucks;

  _PopularSearchTileData({
    required this.title,
    required this.imagePath,
    required this.fetchTrucks,
  });
}
