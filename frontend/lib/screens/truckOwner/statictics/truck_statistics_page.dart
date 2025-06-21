// lib/screens/truckOwner/orders/truck_statistics_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:myapp/core/services/truckOwner_service.dart';
import 'package:myapp/screens/truckOwner/manage%20bookings/widgets/truck_selector_dropdown.dart';
import 'package:myapp/screens/truckOwner/statictics/widgets/bookings_calendar_view.dart';
import 'package:myapp/screens/truckOwner/statictics/widgets/daily_orders_chart.dart';
import 'package:myapp/screens/truckOwner/statictics/widgets/most_ordered_items_chart.dart';
import 'package:myapp/screens/truckOwner/statictics/widgets/top_rated_items_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Renamed page
class TruckStatisticsPage extends StatefulWidget {
  const TruckStatisticsPage({super.key});

  @override
  State<TruckStatisticsPage> createState() => _TruckStatisticsPageState();
}

class _TruckStatisticsPageState extends State<TruckStatisticsPage> {
  List<dynamic> trucks = [];
  String? selectedTruckId;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadTrucks();
  }

  Future<void> _loadTrucks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) throw Exception("Authorization token not found");

      final response = await TruckOwnerService.getMyTrucks(token);
      if (response.statusCode == 200) {
        final List<dynamic> truckList = jsonDecode(response.body);
        setState(() {
          trucks = truckList;
          if (truckList.isNotEmpty) {
            selectedTruckId = truckList[0]['_id'];
          }
          isLoading = false;
        });
      } else {
        throw Exception(
            'Failed to load trucks (status ${response.statusCode})');
      }
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  void _onTruckChanged(String? newId) {
    setState(() {
      selectedTruckId = newId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 253, 236, 217),
      appBar: AppBar(
        title: const Text("Truck Statistics"),
        backgroundColor: const Color(0xFFFF600A),
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(
        child: Text(
          "⚠️ Failed to load trucks:\n$error",
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.red),
        ),
      )
          : Column(
        children: [
          TruckSelectorDropdown(
            trucks: trucks,
            selectedTruckId: selectedTruckId,
            onChanged: _onTruckChanged,
          ),
          if (selectedTruckId != null)
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // --- NEW CALENDAR VIEW ---
                    BookingsCalendarView(truckId: selectedTruckId!),

                    const SizedBox(height: 16),
                    DailyOrdersChart(truckId: selectedTruckId!),

                    const SizedBox(height: 16),
                    MostOrderedItemsChart(truckId: selectedTruckId!),

                    const SizedBox(height: 16),
                    TopRatedItemsChart(truckId: selectedTruckId!),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            )
          else
            const Expanded(
              child: Center(
                child:
                Text("No trucks available to show statistics."),
              ),
            ),
        ],
      ),
    );
  }
}