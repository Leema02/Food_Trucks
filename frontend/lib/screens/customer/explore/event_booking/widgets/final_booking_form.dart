import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/core/services/event_booking_service.dart';
import 'package:myapp/core/services/menu_service.dart';

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
  final locationController = TextEditingController();
  final guestsController = TextEditingController();
  final requestsController = TextEditingController();

  TimeOfDay? startTime;
  TimeOfDay? endTime;
  double? estimatedTotal;

  @override
  void initState() {
    super.initState();
    guestsController.addListener(_onGuestCountChanged);
  }

  void _onGuestCountChanged() {
    final guests = int.tryParse(guestsController.text.trim());
    if (guests != null && guests > 0) {
      calculateEstimatedTotal(guests);
    } else {
      setState(() => estimatedTotal = null);
    }
  }

//avg menu price of the selected truck × guest count
  Future<void> calculateEstimatedTotal(int guestCount) async {
    try {
      final res = await MenuService.getMenuItems(widget.truck["_id"]);
      if (res.statusCode == 200) {
        final List<dynamic> items = jsonDecode(res.body);
        if (items.isEmpty) return;
        final prices = items.map((i) => i['price'] as num).toList();
        final avgPrice = prices.reduce((a, b) => a + b) / prices.length;
        setState(() => estimatedTotal = avgPrice * guestCount);
      }
    } catch (e) {
      print("❌ Failed to estimate total: $e");
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate() ||
        startTime == null ||
        endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please complete all required fields.")),
      );
      return;
    }

    final data = {
      "truck_id": widget.truck["_id"],
      "event_start_date": widget.selectedDateRange.start.toIso8601String(),
      "event_end_date": widget.selectedDateRange.end.toIso8601String(),
      "start_time": startTime!.format(context),
      "end_time": endTime!.format(context),
      "occasion_type": "N/A",
      "location": locationController.text.trim(),
      "city": widget.truck["city"],
      "guest_count": int.tryParse(guestsController.text.trim()),
      "special_requests": requestsController.text.trim(),
      "total_amount": estimatedTotal ?? 0,
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
                onTap: _pickStartTime,
                child: AbsorbPointer(
                  child: _buildField(
                    label: "Start Time",
                    hint: "Select start time",
                    controller: TextEditingController(
                      text: startTime?.format(context) ?? '',
                    ),
                    validator: (_) =>
                        startTime == null ? 'Please select a start time' : null,
                  ),
                ),
              ),
              GestureDetector(
                onTap: _pickEndTime,
                child: AbsorbPointer(
                  child: _buildField(
                    label: "End Time",
                    hint: "Select end time",
                    controller: TextEditingController(
                      text: endTime?.format(context) ?? '',
                    ),
                    validator: (_) =>
                        endTime == null ? 'Please select an end time' : null,
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
              if (estimatedTotal != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Estimated Total:",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      Text("₪${estimatedTotal!.toStringAsFixed(2)}",
                          style: const TextStyle(
                              fontSize: 16, color: Colors.green)),
                    ],
                  ),
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

  Future<void> _pickStartTime() async {
    final time =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (time != null) setState(() => startTime = time);
  }

  Future<void> _pickEndTime() async {
    final time =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (time != null) setState(() => endTime = time);
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
