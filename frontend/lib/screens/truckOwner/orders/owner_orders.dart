import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myapp/core/services/order_service.dart';
import 'package:myapp/core/services/truckOwner_service.dart';
import 'package:myapp/screens/auth/widgets/auth_background.dart';
//import 'package:intl/intl.dart';
import 'package:easy_localization/easy_localization.dart';

class OwnerOrdersPage extends StatefulWidget {
  const OwnerOrdersPage({super.key});

  @override
  State<OwnerOrdersPage> createState() => _OwnerOrdersPageState();
}

class _OwnerOrdersPageState extends State<OwnerOrdersPage> {
  String formatOrderTime(String isoDate) {
    try {
      final dateTime = DateTime.parse(isoDate).toLocal();
      return DateFormat('MMM d, yyyy • hh:mm a').format(dateTime);
    } catch (_) {
      return 'unknown_time'.tr();
    }
  }

  List<dynamic> trucks = [];
  List<dynamic> orders = [];
  String? selectedTruckId;
  bool isLoading = true;

  final List<String> statuses = ['Pending', 'Preparing', 'Ready', 'Completed'];

  @override
  void initState() {
    super.initState();
    fetchTrucks();
  }

  Future<void> fetchTrucks() async {
    setState(() => isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final response = await TruckOwnerService.getMyTrucks(token);
    if (response.statusCode == 200) {
      final fetchedTrucks = jsonDecode(response.body);
      setState(() {
        trucks = fetchedTrucks;
        if (trucks.isNotEmpty) {
          selectedTruckId = trucks[0]['_id'];
          fetchOrdersForTruck();
        } else {
          isLoading = false;
        }
      });
    } else {
      setState(() => isLoading = false);
      _showMessage('failed_to_load_trucks'.tr());
    }
  }

  Future<void> fetchOrdersForTruck() async {
    if (selectedTruckId == null) return;

    setState(() => isLoading = true);
    final response = await OrderService.getOrdersByTruck(selectedTruckId!);

    if (response.statusCode == 200) {
      setState(() {
        orders = jsonDecode(response.body);
        isLoading = false;
      });
    } else {
      _showMessage('failed_to_fetch_orders'.tr());
      setState(() => isLoading = false);
    }
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    final response = await OrderService.updateOrderStatus(orderId, newStatus);
    if (response.statusCode == 200) {
      fetchOrdersForTruck();
    } else {
      _showMessage('failed_to_update_status'.tr());
    }
  }

  String normalizeStatus(String status) {
    return statuses.firstWhere(
      (s) => s.toLowerCase() == status.toLowerCase(),
      orElse: () => statuses[0],
    );
  }

  void _showMessage(String message) {
    final snackBar = SnackBar(
      content: Text(message, textAlign: TextAlign.center),
      backgroundColor: const Color.fromARGB(255, 89, 56, 39),
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  String getCustomerNameFromOrder(dynamic customerData) {
    if (customerData is Map<String, dynamic>) {
      final fName = customerData['F_name'] ?? '';
      final lName = customerData['L_name'] ?? '';
      return "$fName $lName".trim();
    }
    return 'unknown_customer'.tr();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'orders_by_truck'.tr(),
          style: const TextStyle(fontSize: 22, color: Colors.black),
        ),
        backgroundColor: const Color.fromARGB(255, 255, 136, 0),
      ),
      body: AuthBackground(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: DropdownButtonFormField<String>(
                value: selectedTruckId,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'select_a_Truck'.tr(),
                  border: const OutlineInputBorder(),
                ),
                items: trucks.map<DropdownMenuItem<String>>((truck) {
                  return DropdownMenuItem<String>(
                    value: truck['_id'],
                    child: Text(truck['truck_name']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedTruckId = value;
                    fetchOrdersForTruck();
                  });
                },
              ),
            ),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : orders.isEmpty
                      ? Center(child: Text('no_orders_for_this_truck'.tr()))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: orders.length,
                          itemBuilder: (context, index) {
                            final order = orders[index];
                            final normalizedStatus =
                                normalizeStatus(order['status'] ?? '');
                            final customerName =
                                getCustomerNameFromOrder(order['customer_id']);

                            return Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ExpansionTile(
                                title: Text(
                                  '${'order_by'.tr()} $customerName',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        '${'status'.tr()}: ${normalizedStatus.tr()}'),
                                    Text(
                                        '${'placed_on'.tr()}: ${formatOrderTime(order['createdAt'] ?? '')}'),
                                  ],
                                ),
                                children: [
                                  if (order['items'] != null)
                                    ...List<Widget>.from(
                                        order['items'].map((item) {
                                      return ListTile(
                                        title: Text(item['name']),
                                        subtitle: Text(
                                            '${'qty'.tr()}: ${item['quantity']}'),
                                      );
                                    })),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: DropdownButtonFormField<String>(
                                      value: normalizedStatus,
                                      decoration: InputDecoration(
                                        labelText: 'update_status'.tr(),
                                        border: const OutlineInputBorder(),
                                      ),
                                      items: statuses
                                          .map((status) => DropdownMenuItem(
                                                value: status,
                                                child: Text(status.tr()),
                                              ))
                                          .toList(),
                                      onChanged: (newStatus) {
                                        if (newStatus != null) {
                                          updateOrderStatus(
                                              order['_id'], newStatus);
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
