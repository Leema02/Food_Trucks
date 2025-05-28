import 'package:flutter/material.dart';

class ReviewCard extends StatelessWidget {
  final dynamic review;
  final String? menuItemName;

  const ReviewCard({super.key, required this.review, this.menuItemName});

  @override
  Widget build(BuildContext context) {
    final customer = review['customer_id'];
    final name = customer != null
        ? "${customer['F_name']} ${customer['L_name']}"
        : "Anonymous";

    final rating = review['rating'] ?? 0;
    final comment = review['comment'] ?? '';
    final sentiment = review['sentiment'] ?? 'neutral';

    Color getSentimentColor(String s) {
      switch (s.toLowerCase()) {
        case 'positive':
          return Colors.green;
        case 'negative':
          return Colors.red;
        case 'neutral':
        default:
          return Colors.grey;
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (menuItemName != null) ...[
              Text("🧾 $menuItemName",
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 16)),
              const SizedBox(height: 6),
            ],
            Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Row(
              children: List.generate(
                5,
                (i) => Icon(
                  i < rating ? Icons.star : Icons.star_border,
                  color: Colors.orange,
                  size: 20,
                ),
              ),
            ),
            if (comment.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(comment),
            ],
            const SizedBox(height: 6),
            Chip(
              label: Text(sentiment.toUpperCase()),
              backgroundColor: getSentimentColor(sentiment),
              labelStyle: const TextStyle(color: Colors.white),
            )
          ],
        ),
      ),
    );
  }
}
