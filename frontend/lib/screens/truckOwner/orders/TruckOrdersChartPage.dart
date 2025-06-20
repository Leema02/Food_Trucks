import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:myapp/core/services/truckOwner_service.dart';
import 'package:myapp/screens/truckOwner/manage%20bookings/widgets/truck_selector_dropdown.dart';
import 'package:myapp/screens/truckOwner/orders/truck_orders_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TruckOrdersChartPage extends StatefulWidget {
  const TruckOrdersChartPage({super.key});

  @override
  State<TruckOrdersChartPage> createState() => _TruckOrdersChartPageState();
}

class _TruckOrdersChartPageState extends State<TruckOrdersChartPage> {
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
    // بإمكانك هنا تضيف أي لوجيك إضافي
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color.fromARGB(255, 253, 236, 217), // ← هنا الخلفية الجديدة
      appBar: AppBar(
        title: const Text("Orders Statistics by Truck"),
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
                        child: TruckOrdersChart(truckId: selectedTruckId!),
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
