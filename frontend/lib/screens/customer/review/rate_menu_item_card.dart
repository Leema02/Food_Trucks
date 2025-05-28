import 'package:flutter/material.dart';

class RateMenuItemCard extends StatefulWidget {
  final String itemId;
  final String itemName;
  final String orderId;
  final bool isRated;

  /// 🔁 Callback to update parent state
  final void Function(int rating) onRatingChanged;
  final void Function(String comment) onCommentChanged;

  const RateMenuItemCard({
    super.key,
    required this.itemId,
    required this.itemName,
    required this.orderId,
    required this.isRated,
    required this.onRatingChanged,
    required this.onCommentChanged,
  });

  @override
  State<RateMenuItemCard> createState() => _RateMenuItemCardState();
}

class _RateMenuItemCardState extends State<RateMenuItemCard> {
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
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.itemName,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            if (widget.isRated)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text("✅ Already Rated",
                    style: TextStyle(color: Colors.green)),
              )
            else
              Row(
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < rating ? Icons.star : Icons.star_border,
                      color: Colors.orange,
                    ),
                    onPressed: () => _setRating(index + 1),
                  );
                }),
              ),
            if (!widget.isRated)
              TextField(
                controller: commentController,
                onChanged: widget.onCommentChanged,
                decoration: const InputDecoration(
                  labelText: "Item comment (optional)",
                ),
              )
          ],
        ),
      ),
    );
  }
}
