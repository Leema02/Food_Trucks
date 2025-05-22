import 'package:flutter/material.dart';
import 'package:myapp/screens/customer/explore/event_booking/widgets/final_booking_form.dart';
import 'widgets/truck_calendar.dart';

class TruckBookingScreen extends StatefulWidget {
  final Map<String, dynamic> truck;

  const TruckBookingScreen({super.key, required this.truck});

  @override
  State<TruckBookingScreen> createState() => _TruckBookingScreenState();
}

class _TruckBookingScreenState extends State<TruckBookingScreen> {
  DateTime? selectedDate;
  List<DateTime> unavailableDates = [];

  @override
  void initState() {
    super.initState();
    _loadUnavailableDates();
  }

  void _loadUnavailableDates() {
    final List<String> raw =
        List<String>.from(widget.truck['unavailable_dates'] ?? []);
    unavailableDates = raw.map((dateStr) => DateTime.parse(dateStr)).toList();
  }

  void _onContinue() {
    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a date")),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FinalBookingForm(
          truck: widget.truck,
          selectedDate: selectedDate!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final truck = widget.truck;

    return Scaffold(
      appBar: AppBar(
        title: Text(truck['truck_name'] ?? 'Truck Booking'),
        backgroundColor: Colors.orange,
      ),
      body: Column(
        children: [
          // 🛻 Truck Summary
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  truck['truck_name'] ?? '',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text("Cuisine: ${truck['cuisine_type'] ?? 'N/A'}"),
                Text("City: ${truck['city'] ?? 'N/A'}"),
              ],
            ),
          ),

          // 📅 Calendar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TruckCalendar(
              unavailableDates: unavailableDates,
              onDateSelected: (date) => setState(() => selectedDate = date),
            ),
          ),

          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: _onContinue,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 255, 195, 98),
              foregroundColor: Colors.black, // 🖤 force button text to black
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Continue to Booking"),
          ),
        ],
      ),
    );
  }
}
