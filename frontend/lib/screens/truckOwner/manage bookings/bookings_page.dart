import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/services/event_booking_service.dart';
import '../../../core/services/truckOwner_service.dart';
import 'widgets/booking_card.dart';
import 'widgets/status_filter_chips.dart';
import 'widgets/truck_selector_dropdown.dart';

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
        final matchStatus = (b['status'] ?? '').toString().toLowerCase() ==
            selectedStatus.toLowerCase();
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
          TruckSelectorDropdown(
            trucks: trucks,
            selectedTruckId: selectedTruckId,
            onChanged: (value) {
              setState(() {
                selectedTruckId = value;
                filterBookings();
              });
            },
          ),
          StatusFilterChips(
            selectedStatus: selectedStatus,
            onStatusChanged: (status) {
              setState(() {
                selectedStatus = status;
                filterBookings();
              });
            },
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
                          final booking = filteredBookings[index];
                          return BookingCard(
                            booking: booking,
                            onApprove: () =>
                                confirmBookingWithAmount(booking['_id']),
                            onReject: () => rejectBooking(booking['_id']),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
