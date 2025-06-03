import 'package:flutter/material.dart';
import 'package:myapp/core/services/truckOwner_service.dart';
import 'package:myapp/screens/customer/home/widgets/truck_card.dart';

class FilteredTruckListPage extends StatefulWidget {
  final String cuisine;

  const FilteredTruckListPage({super.key, required this.cuisine});

  @override
  State<FilteredTruckListPage> createState() => _FilteredTruckListPageState();
}

class _FilteredTruckListPageState extends State<FilteredTruckListPage> {
  List<dynamic> trucks = [];
  bool isLoading = true;
  bool isError = false;

  @override
  void initState() {
    super.initState();
    fetchTrucks();
  }

  Future<void> fetchTrucks() async {
    try {
      final results =
          await TruckOwnerService.getTrucksByCuisine(widget.cuisine);
      setState(() {
        trucks = results;
        isLoading = false;
      });
    } catch (e) {
      print("❌ Error fetching trucks: $e");
      setState(() {
        isError = true;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.cuisine} Trucks"),
        backgroundColor: const Color.fromARGB(255, 245, 140, 42),
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      backgroundColor: const Color.fromARGB(255, 255, 240, 217),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : isError
              ? _buildErrorView()
              : trucks.isEmpty
                  ? _buildEmptyView()
                  : ListView.builder(
                      itemCount: trucks.length,
                      padding: const EdgeInsets.only(top: 8, bottom: 24),
                      itemBuilder: (context, index) {
                        final truck = trucks[index];
                        return TruckCard(
                          truck: truck,
                          activeSearchTerms: [widget.cuisine],
                        );
                      },
                    ),
    );
  }

  Widget _buildEmptyView() {
    return const Center(
      child: Text(
        "🚫 No trucks found for this cuisine.",
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildErrorView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 40),
          SizedBox(height: 8),
          Text(
            "Failed to load trucks.\nPlease try again later.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
