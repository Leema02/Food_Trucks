import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/core/services/event_booking_service.dart';

class FinalBookingForm extends StatefulWidget {
  final Map<String, dynamic> truck;
  final DateTime selectedDate;

  const FinalBookingForm({
    super.key,
    required this.truck,
    required this.selectedDate,
  });

  @override
  State<FinalBookingForm> createState() => _FinalBookingFormState();
}

class _FinalBookingFormState extends State<FinalBookingForm> {
  TimeOfDay? selectedTime;
  final TextEditingController locationController = TextEditingController();
  final TextEditingController guestsController = TextEditingController();
  final TextEditingController requestsController = TextEditingController();

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) setState(() => selectedTime = time);
  }

  void _submit() async {
    if (selectedTime == null ||
        locationController.text.isEmpty ||
        guestsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields")),
      );
      return;
    }

    final data = {
      "truck_id": widget.truck["_id"],
      "event_date": widget.selectedDate.toIso8601String(),
      "event_time": selectedTime!.format(context),
      "occasion_type": "N/A",
      "location": locationController.text,
      "city": widget.truck["city"],
      "guest_count": int.tryParse(guestsController.text),
      "special_requests": requestsController.text,
      "total_amount": 0
    };

    try {
      final response = await EventBookingService.submitBooking(data);

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Booking submitted successfully!")),
        );
        Navigator.pop(context); // or push confirmation screen
      } else {
        final message =
            jsonDecode(response.body)['message'] ?? 'Something went wrong';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ $message")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final truck = widget.truck;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Complete Booking"),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Truck Summary
            Text(
              truck['truck_name'] ?? '',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text("Date: ${DateFormat.yMMMd().format(widget.selectedDate)}"),

            const SizedBox(height: 16),
            GestureDetector(
              onTap: _pickTime,
              child: AbsorbPointer(
                child: _buildField(
                  label: "Event Time",
                  hint: "Select Time",
                  controller: TextEditingController(
                    text: selectedTime?.format(context) ?? '',
                  ),
                ),
              ),
            ),
            _buildField(label: "Location", controller: locationController),
            _buildField(
              label: "Guest Count",
              controller: guestsController,
              keyboardType: TextInputType.number,
            ),
            _buildField(
              label: "Special Requests (optional)",
              controller: requestsController,
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange.shade200,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: const Text("Submit Booking"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    String? hint,
    TextEditingController? controller,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: Colors.orange.shade50,
        ),
      ),
    );
  }
}
