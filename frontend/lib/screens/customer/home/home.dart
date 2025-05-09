import 'package:flutter/material.dart';
import '../../../core/services/truckOwner_service.dart';

import 'widgets/header_section.dart';
import 'widgets/search_filter_bar.dart';
import 'widgets/truck_card.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<dynamic> trucks = [];
  bool isLoading = true;
  String errorMessage = '';
  String selectedCity = 'Gaza';

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
      final data = await TruckOwnerService.getPublicTrucks();
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
            onCityChange: (newCity) {
              setState(() => selectedCity = newCity);
            },
          ),
          const SearchFilterBar(),
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.orange))
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
