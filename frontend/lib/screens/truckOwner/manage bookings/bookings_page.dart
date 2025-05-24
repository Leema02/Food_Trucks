import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/event_booking_service.dart';
import '../../../core/services/truckOwner_service.dart';
import 'package:easy_localization/easy_localization.dart';

class OwnerBookingsPage extends StatefulWidget {
  const OwnerBookingsPage({super.key});

  @override
  State<OwnerBookingsPage> createState() => _OwnerBookingsPageState();
}

class _OwnerBookingsPageState extends State<OwnerBookingsPage> {
  List<dynamic> trucks = [];
  List<dynamic> allBookings = [];
  List<dynamic> filteredBookings = [];
  String? selectedTruckId;
  String selectedStatus = 'pending';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchTrucks();
  }

  Future<void> fetchTrucks() async {
    setState(() => isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try {
      final response = await TruckOwnerService.getMyTrucks(token!);
      if (response.statusCode == 200) {
        final truckList = jsonDecode(response.body);
        setState(() {
          trucks = truckList;
          if (trucks.isNotEmpty) {
            selectedTruckId = trucks[0]['_id'];
            fetchBookings();
          } else {
            isLoading = false;
          }
        });
      } else {
        showError("failed_to_load_trucks".tr());
        setState(() => isLoading = false);
      }
    } catch (e) {
      showError("error_occurred".tr());
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchBookings() async {
    if (selectedTruckId == null) return;
    setState(() => isLoading = true);

    try {
      final bookings = await EventBookingService.getOwnerBookings();
      setState(() {
        allBookings = bookings;
        filterBookings();
        isLoading = false;
      });
    } catch (e) {
      showError("error_occurred".tr());
      setState(() => isLoading = false);
    }
  }

  void filterBookings() {
    setState(() {
      filteredBookings = allBookings.where((b) {
        final truck = b['truck_id'];
        final matchTruck = truck is Map && truck['_id'] == selectedTruckId;
        final matchStatus = b['status'] == selectedStatus;
        return matchTruck && matchStatus;
      }).toList();
    });
  }

  Future<void> confirmBookingWithAmount(String id) async {
    final amount = await showDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: Text('set_total_amount'.tr()),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: 'enter_total_amount'.tr()),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('cancel'.tr()),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: Text('confirm'.tr()),
            ),
          ],
        );
      },
    );

    if (amount != null && amount.trim().isNotEmpty) {
      try {
        final parsedAmount = double.tryParse(amount.trim());
        if (parsedAmount == null) throw Exception('Invalid amount');

        await EventBookingService.updateBookingStatus(
          id,
          'confirmed',
          totalAmount: parsedAmount,
        );
        showSuccess(
            "booking_confirmed".tr(args: [parsedAmount.toStringAsFixed(2)]));
        fetchBookings();
      } catch (e) {
        showError("failed_to_confirm_booking".tr());
      }
    }
  }

  Future<void> rejectBooking(String id) async {
    try {
      await EventBookingService.updateBookingStatus(id, 'rejected');
      showSuccess("booking_rejected".tr());
      fetchBookings();
    } catch (e) {
      showError("failed_to_reject_booking".tr());
    }
  }

  void showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  void showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("manage_bookings".tr()),
        centerTitle: true,
        backgroundColor: Colors.orange.shade400,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: DropdownButtonFormField<String>(
              value: selectedTruckId,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: "select_a_truck".tr(),
                border: const OutlineInputBorder(),
              ),
              items: trucks.map<DropdownMenuItem<String>>((truck) {
                return DropdownMenuItem<String>(
                  value: truck['_id'],
                  child: Text(truck['truck_name'] ?? "unnamed_truck".tr()),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedTruckId = value;
                  filterBookings();
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                ChoiceChip(
                  label: Text('pending'.tr()),
                  selected: selectedStatus == 'pending',
                  selectedColor: Colors.orange.shade200,
                  onSelected: (_) {
                    setState(() {
                      selectedStatus = 'pending';
                      filterBookings();
                    });
                  },
                ),
                const SizedBox(width: 10),
                ChoiceChip(
                  label: Text('confirmed'.tr()),
                  selected: selectedStatus == 'confirmed',
                  selectedColor: Colors.green.shade200,
                  onSelected: (_) {
                    setState(() {
                      selectedStatus = 'confirmed';
                      filterBookings();
                    });
                  },
                ),
                const SizedBox(width: 10),
                ChoiceChip(
                  label: Text('rejected'.tr()),
                  selected: selectedStatus == 'rejected',
                  selectedColor: Colors.red.shade200,
                  onSelected: (_) {
                    setState(() {
                      selectedStatus = 'rejected';
                      filterBookings();
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredBookings.isEmpty
                    ? Center(child: Text("no_bookings_found".tr()))
                    : ListView.builder(
                        itemCount: filteredBookings.length,
                        itemBuilder: (context, index) {
                          final b = filteredBookings[index];
                          final customer = b['user_id'];
                          final date =
                              b['event_date']?.toString().split('T').first ??
                                  '';
                          final time = b['event_time'] ?? '';
                          final guests = b['guest_count']?.toString() ?? '0';

                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.event, color: Colors.orange),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text("${'event'.tr()}: $date at $time",
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 6),
                                        Text("${'guests'.tr()}: $guests"),
                                        Text(
                                            "${'customer'.tr()}: ${customer['F_name']} ${customer['L_name']}"),
                                        Text(
                                            "${'email'.tr()}: ${customer['email_address']}"),
                                        Text(
                                            "${'phone'.tr()}: ${customer['phone_num'] ?? 'N/A'}"),
                                        if (b['status'] == 'confirmed' &&
                                            b['total_amount'] != null)
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 8.0),
                                            child: Text(
                                              "💰 ${'total_amount'.tr()}: ₪${b['total_amount'].toStringAsFixed(2)}",
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.green,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  selectedStatus == 'pending'
                                      ? Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(
                                                  Icons.check_circle,
                                                  color: Colors.green),
                                              tooltip: 'approve'.tr(),
                                              onPressed: () =>
                                                  confirmBookingWithAmount(
                                                      b['_id']),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.cancel,
                                                  color: Colors.red),
                                              tooltip: 'reject'.tr(),
                                              onPressed: () =>
                                                  rejectBooking(b['_id']),
                                            ),
                                          ],
                                        )
                                      : const Icon(Icons.info_outline,
                                          color: Colors.grey),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
