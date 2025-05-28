import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myapp/core/services/review_service.dart';
import 'package:myapp/core/services/truckOwner_service.dart';
import 'package:myapp/screens/truckOwner/check Reviews/widgets/sentiment_filter_chips.dart';
import 'package:myapp/screens/truckOwner/check Reviews/widgets/review_card.dart';

import '../../manage bookings/widgets/truck_selector_dropdown.dart';

class OwnerTruckReviewsTab extends StatefulWidget {
  const OwnerTruckReviewsTab({super.key});

  @override
  State<OwnerTruckReviewsTab> createState() => _OwnerTruckReviewsTabState();
}

class _OwnerTruckReviewsTabState extends State<OwnerTruckReviewsTab> {
  List<dynamic> trucks = [];
  String? selectedTruckId;
  List<dynamic> allReviews = [];
  String selectedSentiment = 'All';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTrucks();
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
            fetchTruckReviews();
          } else {
            isLoading = false;
          }
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchTruckReviews() async {
    if (selectedTruckId == null) return;

    setState(() => isLoading = true);
    try {
      final response = await ReviewService.fetchTruckReviews(selectedTruckId!);
      setState(() {
        allReviews = response;
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
              fetchTruckReviews();
            });
          },
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
                return ReviewCard(review: filtered[index]);
              },
            ),
          )
      ],
    );
  }
}
