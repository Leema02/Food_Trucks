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
  DateTimeRange? selectedDateRange;
  bool hasUnavailableInSelection = false;
  List<DateTime> unavailableDates = [];

  @override
  void initState() {
    super.initState();
    _loadUnavailableDates();
  }

  void _loadUnavailableDates() {
    final rawDates = List<String>.from(widget.truck['unavailable_dates'] ?? []);
    unavailableDates =
        rawDates.map((dateStr) => DateTime.parse(dateStr)).toList();
  }

  void _onContinue() {
    if (selectedDateRange == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a date range.")),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FinalBookingForm(
          truck: widget.truck,
          selectedDateRange: selectedDateRange!,
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🛻 Truck Info
            Container(
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

            const SizedBox(height: 16),

            // 📅 Calendar
            TruckCalendar(
              unavailableDates: unavailableDates,
              onRangeSelected: (start, end, hasUnavailable) {
                setState(() {
                  selectedDateRange = DateTimeRange(start: start, end: end);
                  hasUnavailableInSelection = hasUnavailable;
                });
              },
            ),

            // 📌 Selected Range Display
            if (selectedDateRange != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Column(
                  children: [
                    Text(
                      'Selected: ${selectedDateRange!.start.toString().split(" ")[0]} → ${selectedDateRange!.end.toString().split(" ")[0]}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (hasUnavailableInSelection)
                      const Padding(
                        padding: EdgeInsets.only(top: 6),
                        child: Text(
                          "⚠️ Your selected range includes unavailable dates.",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                  ],
                ),
              ),

            const SizedBox(height: 24),

            // 🔘 Continue Button
            ElevatedButton(
              onPressed: _onContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 255, 195, 98),
                foregroundColor: Colors.black,
                padding:
                    const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text("Continue to Booking"),
            ),
          ],
        ),
      ),
    );
  }
}
