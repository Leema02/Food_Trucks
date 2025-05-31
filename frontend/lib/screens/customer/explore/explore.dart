import 'package:flutter/material.dart';
import 'package:myapp/screens/customer/explore/event_booking/widgets/event_booking_selector.dart';
import 'widgets/explore_tab_bar.dart';
import 'widgets/popular_searches.dart';
import 'widgets/cuisine_grid.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F8F8),
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 8),

              // 🔍 Tab Bar (Food Trucks | Event Booking)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: ExploreTabBar(),
              ),

              // 📄 Content Tabs
              const Expanded(
                child: TabBarView(
                  children: [
                    _FoodTrucksTabContent(),
                    EventBookingSelector(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 🧩 Food Trucks Tab Content
class _FoodTrucksTabContent extends StatelessWidget {
  const _FoodTrucksTabContent();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 12),
      children: const [
        PopularSearchesSection(),
        SizedBox(height: 16),
        CuisineGridSection(),
      ],
    );
  }
}
