// lib/screens/truckOwner/orders/widgets/menu_item_info_dialog.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MenuItemInfoDialog extends StatelessWidget {
  final Map<String, dynamic> menuItem;

  const MenuItemInfoDialog({
    super.key,
    required this.menuItem,
  });

  @override
  Widget build(BuildContext context) {
    final String? imageUrl = menuItem['image_url'];
    final String name = menuItem['name'] ?? 'No Name';
    final double price = (menuItem['price'] as num?)?.toDouble() ?? 0.0;
    final String description = menuItem['description'] ?? 'No description available.';

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 8,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 300,
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min, // To make the dialog wrap content
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Image Section ---
              if (imageUrl != null)
                CachedNetworkImage(
                  imageUrl: imageUrl.startsWith('http')
                      ? imageUrl
                      : 'http://10.0.2.2:5000$imageUrl',
                  height: 150,
                  fit: BoxFit.cover,
                  placeholder: (ctx, url) => Container(
                    height: 150,
                    color: Colors.grey.shade200,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (ctx, url, err) => Container(
                    height: 150,
                    color: Colors.grey.shade100,
                    child: const Center(
                        child: Icon(Icons.broken_image,
                            color: Colors.grey, size: 40)),
                  ),
                ),
              // --- Details Section ---
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Color(0xFF4E342E),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '₪${price.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.deepOrange.shade600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // --- Close Button ---
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}