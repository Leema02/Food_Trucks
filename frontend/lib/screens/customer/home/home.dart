import 'package:flutter/material.dart';
import '../../../core/services/truckOwner_service.dart';
import '../../../core/constants/supported_cities.dart';
import 'widgets/header_section.dart';
import '../explore/widgets/search_filter_bar.dart';
import 'widgets/truck_card.dart';
import 'customer_map.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<dynamic> trucks = [];
  bool isLoading = true;
  String errorMessage = '';
  String selectedCity = 'Qalqilya';
  bool _isMapView = false;

  @override
  void initState() {
    super.initState();
    fetchPublicTrucks();
  }

  Future<void> fetchPublicTrucks() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final data = await TruckOwnerService.getPublicTrucks(city: selectedCity);
      setState(() {
        trucks = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Widget _buildToggleButton(String label, bool value) {
    final isSelected = value == _isMapView;

    return GestureDetector(
      onTap: () async {
        if (value != _isMapView) {
          setState(() => _isMapView = value);

          if (value) {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CustomerMapPage(),
              ),
            );
            setState(() => _isMapView = false);
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.orange : Colors.grey,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        title: const Text('Food Trucks Near You'),
        backgroundColor: Colors.orange,
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          HeaderSection(
            city: selectedCity,
            supportedCities: supportedCities, // 🔁 Shared list
            onCityChange: (newCity) {
              setState(() => selectedCity = newCity);
              fetchPublicTrucks();
            },
          ),
          const SearchFilterBar(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 6),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildToggleButton('List View', false),
                  const VerticalDivider(width: 1, color: Colors.black26),
                  _buildToggleButton('Map View', true),
                ],
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.orange),
                  )
                : errorMessage.isNotEmpty
                    ? Center(child: Text(errorMessage))
                    : trucks.isEmpty
                        ? const Center(child: Text("No food trucks found 😢"))
                        : ListView.builder(
                            itemCount: trucks.length,
                            itemBuilder: (context, index) {
                              return TruckCard(truck: trucks[index]);
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
