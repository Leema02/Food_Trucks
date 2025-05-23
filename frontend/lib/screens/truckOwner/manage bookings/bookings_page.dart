import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/event_booking_service.dart';
import '../../../core/services/truckOwner_service.dart';

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
        showError('Failed to load trucks');
        setState(() => isLoading = false);
      }
    } catch (e) {
      showError(e.toString());
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
      showError('Failed to fetch bookings');
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
          title: const Text('Set Total Amount'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration:
                const InputDecoration(hintText: 'Enter total amount (₪)'),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),
            TextButton(
                onPressed: () => Navigator.pop(context, controller.text),
                child: const Text('Confirm')),
          ],
        );
      },
    );

    if (amount != null && amount.trim().isNotEmpty) {
      try {
        final parsedAmount = double.tryParse(amount.trim());
        if (parsedAmount == null) throw Exception('Invalid amount');

        await EventBookingService.updateBookingStatus(id, 'confirmed',
            totalAmount: parsedAmount);
        showSuccess("Booking confirmed with ₪$parsedAmount");
        fetchBookings();
      } catch (e) {
        showError('Failed to confirm booking');
      }
    }
  }

  Future<void> rejectBooking(String id) async {
    try {
      await EventBookingService.updateBookingStatus(id, 'rejected');
      showSuccess("Booking rejected");
      fetchBookings();
    } catch (e) {
      showError('Failed to reject booking');
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
        title: const Text("Manage Bookings"),
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
              decoration: const InputDecoration(
                labelText: "Select a Truck",
                border: OutlineInputBorder(),
              ),
              items: trucks.map<DropdownMenuItem<String>>((truck) {
                return DropdownMenuItem<String>(
                  value: truck['_id'],
                  child: Text(truck['truck_name'] ?? 'Unnamed Truck'),
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
                  label: const Text('Pending'),
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
                  label: const Text('Confirmed'),
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
                  label: const Text('Rejected'),
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
                    ? const Center(child: Text("No bookings found."))
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
                                borderRadius: BorderRadius.circular(12)),
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
                                        Text("Event: $date at $time",
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 6),
                                        Text("Guests: $guests"),
                                        Text(
                                            "Customer: ${customer['F_name']} ${customer['L_name']}"),
                                        Text(
                                            "Email: ${customer['email_address']}"),
                                        Text(
                                            "Phone: ${customer['phone_num'] ?? 'N/A'}"),
                                        if (b['status'] == 'confirmed' &&
                                            b['total_amount'] != null)
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 8.0),
                                            child: Text(
                                              "💰 Total Amount: ₪${b['total_amount'].toStringAsFixed(2)}",
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
                                              tooltip: 'Approve',
                                              onPressed: () =>
                                                  confirmBookingWithAmount(
                                                      b['_id']),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.cancel,
                                                  color: Colors.red),
                                              tooltip: 'Reject',
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
