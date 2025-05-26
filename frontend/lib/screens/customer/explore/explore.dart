import 'package:flutter/material.dart';
import 'package:myapp/screens/customer/explore/event_booking/widgets/event_booking_selector.dart';
import 'widgets/explore_tab_bar.dart';
import 'widgets/search_filter_bar.dart';
import 'widgets/category.dart';

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

              // 🍊 Search + Filter Bar
              //SearchFilterBar(),

              const SizedBox(height: 4),

              // 🍊 Tab Bar (Food Trucks | Event Booking)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: ExploreTabBar(),
              ),

              // 🧾 Content Tabs
              const Expanded(
                child: TabBarView(
                  children: [
                    CategorySection(),
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
