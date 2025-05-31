import 'package:flutter/material.dart';
import 'package:myapp/core/services/truckOwner_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CuisineGridSection extends StatefulWidget {
  final Function(String cuisine)? onCuisineSelected;

  const CuisineGridSection({super.key, this.onCuisineSelected});

  @override
  State<CuisineGridSection> createState() => _CuisineGridSectionState();
}

class _CuisineGridSectionState extends State<CuisineGridSection> {
  List<String> cuisines = [];
  bool isLoading = true;

  final Map<String, String> cuisineImages = {
    "Multi-Cuisine": "assets/multi.jpg",
    "American": "assets/american.jpg",
    "Asian": "assets/asian.jpg",
    "BBQ": "assets/bbq.jpg",
    "Brazilian": "assets/brazilian.jpg",
    "Breakfast": "assets/breakfast.jpg",
  };

  @override
  void initState() {
    super.initState();
    _loadCuisines();
  }

  Future<void> _loadCuisines() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final data = await TruckOwnerService.getAllCuisines(token);
      setState(() {
        cuisines = data;
        isLoading = false;
      });
    } catch (e) {
      print("❌ Error loading cuisines: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text("Cuisine",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 12),
        isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: cuisines.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.4,
                  ),
                  itemBuilder: (context, index) {
                    final cuisine = cuisines[index];
                    final image =
                        cuisineImages[cuisine] ?? 'assets/default.jpg';

                    return GestureDetector(
                      onTap: () => widget.onCuisineSelected?.call(cuisine),
                      child: _buildCuisineTile(cuisine, image),
                    );
                  },
                ),
              ),
      ],
    );
  }

  Widget _buildCuisineTile(String label, String imagePath) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(imagePath, fit: BoxFit.cover),
            Container(color: Colors.black38),
            Center(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  shadows: [Shadow(blurRadius: 8, color: Colors.black)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
