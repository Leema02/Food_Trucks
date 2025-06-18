// lib/screens/truckOwner/check Reviews/widgets/owner_menu_reviews_tab.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:myapp/screens/truckOwner/check%20Reviews/widgets/sentiment_pie_chart.dart'; // Import the chart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myapp/core/services/review_service.dart';
import 'package:myapp/core/services/menu_service.dart';
import 'package:myapp/core/services/truckOwner_service.dart';
import 'package:myapp/screens/truckOwner/check Reviews/widgets/sentiment_filter_chips.dart';
import 'package:myapp/screens/truckOwner/check Reviews/widgets/review_card.dart';
import '../../manage bookings/widgets/truck_selector_dropdown.dart';

class OwnerMenuReviewsTab extends StatefulWidget {
  const OwnerMenuReviewsTab({super.key});

  @override
  State<OwnerMenuReviewsTab> createState() => _OwnerMenuReviewsTabState();
}

class _OwnerMenuReviewsTabState extends State<OwnerMenuReviewsTab> {
  List<dynamic> trucks = [];
  String? selectedTruckId;
  List<dynamic> allReviews = [];
  Map<String, String> menuItemNames = {};
  String selectedSentiment = 'All';
  bool isLoading = true;

  // New state variables for chart data
  int positiveCount = 0;
  int neutralCount = 0;
  int negativeCount = 0;

  @override
  void initState() {
    super.initState();
    fetchTrucks();
  }

  // New function to calculate counts
  void _calculateSentimentCounts(List<dynamic> reviews) {
    positiveCount = 0;
    neutralCount = 0;
    negativeCount = 0;

    for (var review in reviews) {
      final sentiment = (review['sentiment'] ?? '').toLowerCase();
      if (sentiment == 'positive') {
        positiveCount++;
      } else if (sentiment == 'neutral') {
        neutralCount++;
      } else if (sentiment == 'negative') {
        negativeCount++;
      }
    }
  }

  Future<void> fetchTrucks() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return;

    try {
      final response = await TruckOwnerService.getMyTrucks(token);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          trucks = data;
          if (trucks.isNotEmpty) {
            selectedTruckId = trucks[0]['_id'];
            fetchMenuItemReviews();
          } else {
            isLoading = false;
          }
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchMenuItemReviews() async {
    if (selectedTruckId == null) return;

    setState(() {
      isLoading = true;
      allReviews = [];
      menuItemNames = {};
    });

    try {
      final response = await MenuService.getMenuItems(selectedTruckId!);
      if (response.statusCode != 200) {
        setState(() => isLoading = false);
        return;
      }

      final List<dynamic> menuItems = jsonDecode(response.body);
      final Map<String, String> namesMap = {};
      List<dynamic> allFetched = [];

      for (final item in menuItems) {
        final id = item['_id'];
        final name = item['name'];
        namesMap[id] = name;

        final reviews = await ReviewService.fetchMenuItemReviews2(id);
        allFetched.addAll(reviews);
      }

      _calculateSentimentCounts(allFetched); // Calculate counts here

      setState(() {
        allReviews = allFetched;
        menuItemNames = namesMap;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  List<dynamic> getFilteredReviews() {
    if (selectedSentiment == 'All') return allReviews;
    return allReviews
        .where((r) =>
            (r['sentiment'] ?? '').toLowerCase() ==
            selectedSentiment.toLowerCase())
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = getFilteredReviews();

    return Column(
      children: [
        TruckSelectorDropdown(
          trucks: trucks,
          selectedTruckId: selectedTruckId,
          onChanged: (id) {
            setState(() {
              selectedTruckId = id;
              fetchMenuItemReviews();
            });
          },
        ),
        // Add the chart here
        if (!isLoading && allReviews.isNotEmpty)
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: SentimentPieChart(
              positiveCount: positiveCount,
              neutralCount: neutralCount,
              negativeCount: negativeCount,
            ),
          ),
        SentimentFilterChips(
          selected: selectedSentiment,
          onChanged: (val) => setState(() => selectedSentiment = val),
        ),
        if (isLoading)
          const Expanded(child: Center(child: CircularProgressIndicator()))
        else if (filtered.isEmpty)
          const Expanded(child: Center(child: Text("No reviews found.")))
        else
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final review = filtered[index];
                final itemName =
                    review['menu_item_id']?['name'] ?? 'Unnamed Item';
                return ReviewCard(review: review, menuItemName: itemName);
              },
            ),
          ),
      ],
    );
  }
}
