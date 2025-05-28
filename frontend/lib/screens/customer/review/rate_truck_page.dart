import 'package:flutter/material.dart';
import 'package:myapp/core/services/review_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'rate_truck_section.dart';
import 'rate_menu_item_card.dart';

class RateTruckPage extends StatefulWidget {
  final String orderId;
  final String truckId;
  final List<dynamic> items;

  const RateTruckPage({
    super.key,
    required this.orderId,
    required this.truckId,
    required this.items,
  });

  @override
  State<RateTruckPage> createState() => _RateTruckPageState();
}

class _RateTruckPageState extends State<RateTruckPage> {
  int truckRating = 0;
  String truckComment = '';
  bool isTruckRated = false;
  final Map<String, int> itemRatings = {};
  final Map<String, String> itemComments = {};
  final Map<String, bool> itemRatedMap = {};
  bool isLoading = true;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> _loadRatingStatus() async {
    final token = await _getToken();
    if (token == null) return;

    final truckRated = await ReviewService.checkIfTruckRated(
      token: token,
      orderId: widget.orderId,
      truckId: widget.truckId,
    );

    final itemMap = <String, bool>{};
    for (final item in widget.items) {
      final itemId = item['menu_id'] ?? item['item_id'] ?? '';
      if (itemId.isNotEmpty) {
        final isRated = await ReviewService.checkIfMenuItemRated(
          token: token,
          orderId: widget.orderId,
          itemId: itemId,
        );
        itemMap[itemId] = isRated;
      }
    }

    setState(() {
      isTruckRated = truckRated;
      itemRatedMap.addAll(itemMap);
      isLoading = false;
    });
  }

  Future<void> _submitReviews() async {
    final token = await _getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Missing token")),
      );
      return;
    }

    if (!isTruckRated && truckRating > 0) {
      await ReviewService.submitTruckReview(
        token: token,
        truckId: widget.truckId,
        orderId: widget.orderId,
        rating: truckRating,
        comment: truckComment,
      );
    }

    for (final item in widget.items) {
      final itemId = item['menu_id'] ?? item['item_id'] ?? '';
      if (!(itemRatedMap[itemId] ?? false) &&
          itemRatings[itemId] != null &&
          itemRatings[itemId]! > 0) {
        await ReviewService.submitMenuItemReview(
          token: token,
          menuItemId: itemId,
          orderId: widget.orderId,
          rating: itemRatings[itemId]!,
          comment: itemComments[itemId] ?? '',
        );
      }
    }

    if (context.mounted) {
      Navigator.pop(context, true); // ✅ Return true to trigger refresh
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Reviews submitted")),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadRatingStatus();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Rate Truck & Items")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            RateTruckSection(
              truckId: widget.truckId,
              orderId: widget.orderId,
              isRated: isTruckRated,
              onRatingChanged: (rating) => truckRating = rating,
              onCommentChanged: (text) => truckComment = text,
            ),
            const Divider(height: 32),
            const Text("Rate Ordered Items",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...widget.items.map((item) {
              final itemId = item['menu_id'] ?? item['item_id'] ?? '';
              return RateMenuItemCard(
                itemId: itemId,
                itemName: item['name'] ?? '',
                orderId: widget.orderId,
                isRated: itemRatedMap[itemId] ?? false,
                onRatingChanged: (rating) => itemRatings[itemId] = rating,
                onCommentChanged: (text) => itemComments[itemId] = text,
              );
            }),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitReviews,
              child: const Text("Submit All"),
            )
          ],
        ),
      ),
    );
  }
}
