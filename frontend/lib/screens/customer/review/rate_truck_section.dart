import 'package:flutter/material.dart';

class RateTruckSection extends StatefulWidget {
  final String truckId;
  final String orderId;
  final bool isRated;

  final void Function(int rating) onRatingChanged;
  final void Function(String comment) onCommentChanged;

  const RateTruckSection({
    super.key,
    required this.truckId,
    required this.orderId,
    required this.isRated,
    required this.onRatingChanged,
    required this.onCommentChanged,
  });

  @override
  State<RateTruckSection> createState() => _RateTruckSectionState();
}

class _RateTruckSectionState extends State<RateTruckSection> {
  int rating = 0;
  final TextEditingController commentController = TextEditingController();

  void _setRating(int value) {
    if (!widget.isRated) {
      setState(() => rating = value);
      widget.onRatingChanged(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: widget.isRated ? Colors.grey.shade100 : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Rate This Truck",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            if (widget.isRated) ...[
              Row(
                children: const [
                  Icon(Icons.check_circle, color: Colors.green, size: 20),
                  SizedBox(width: 6),
                  Text(
                    "Already Rated",
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ] else ...[
              Row(
                children: List.generate(
                  5,
                  (index) => IconButton(
                    icon: Icon(
                      index < rating ? Icons.star : Icons.star_border,
                      color: Colors.orange,
                    ),
                    onPressed: () => _setRating(index + 1),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: commentController,
                onChanged: widget.onCommentChanged,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Write a comment",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
