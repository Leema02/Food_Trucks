import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/core/services/event_booking_service.dart';

class FinalBookingForm extends StatefulWidget {
  final Map<String, dynamic> truck;
  final DateTimeRange selectedDateRange;

  const FinalBookingForm({
    super.key,
    required this.truck,
    required this.selectedDateRange,
  });

  @override
  State<FinalBookingForm> createState() => _FinalBookingFormState();
}

class _FinalBookingFormState extends State<FinalBookingForm> {
  final _formKey = GlobalKey<FormState>();

  TimeOfDay? selectedTime;
  final locationController = TextEditingController();
  final guestsController = TextEditingController();
  final requestsController = TextEditingController();

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) setState(() => selectedTime = time);
  }

  void _submit() async {
    if (!_formKey.currentState!.validate() || selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please complete all required fields.")),
      );
      return;
    }

    final data = {
      "truck_id": widget.truck["_id"],
      "event_start_date": widget.selectedDateRange.start.toIso8601String(),
      "event_end_date": widget.selectedDateRange.end.toIso8601String(),
      "event_time": selectedTime!.format(context),
      "occasion_type": "N/A",
      "location": locationController.text.trim(),
      "city": widget.truck["city"],
      "guest_count": int.tryParse(guestsController.text.trim()),
      "special_requests": requestsController.text.trim(),
      "total_amount": 0,
    };

    try {
      final response = await EventBookingService.submitBooking(data);
      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Booking submitted successfully!")),
        );
        Navigator.pop(context);
      } else {
        final message =
            jsonDecode(response.body)['message'] ?? 'Something went wrong.';
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
    final start = DateFormat.yMMMd().format(widget.selectedDateRange.start);
    final end = DateFormat.yMMMd().format(widget.selectedDateRange.end);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Complete Booking"),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text(
                truck['truck_name'] ?? '',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text("Dates: $start → $end"),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _pickTime,
                child: AbsorbPointer(
                  child: _buildField(
                    label: "Event Time",
                    hint: "Select time",
                    controller: TextEditingController(
                      text: selectedTime?.format(context) ?? '',
                    ),
                    validator: (_) =>
                        selectedTime == null ? 'Please select a time' : null,
                  ),
                ),
              ),
              _buildField(
                label: "Location",
                controller: locationController,
                validator: (val) =>
                    val == null || val.trim().isEmpty ? "Required" : null,
              ),
              _buildField(
                label: "Guest Count",
                controller: guestsController,
                keyboardType: TextInputType.number,
                validator: (val) => val == null || int.tryParse(val) == null
                    ? "Enter a valid number"
                    : null,
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
      ),
    );
  }

  Widget _buildField({
    required String label,
    String? hint,
    TextEditingController? controller,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
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
