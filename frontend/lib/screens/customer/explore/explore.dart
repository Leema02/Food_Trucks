import 'package:flutter/material.dart';
import 'package:myapp/screens/auth/widgets/auth_background.dart';
import 'package:myapp/screens/customer/explore/event_booking/widgets/event_booking_selector.dart';
import 'package:myapp/screens/customer/explore/widgets/filtered_trucks.dart';
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
        backgroundColor: Colors.transparent, // Let gradient show
        body: AuthBackground(
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 8),

                // 🔍 Tab Bar (Food Trucks | Event Booking)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: ExploreTabBar(),
                ),

                // 📄 Tab Content
                Expanded(
                  child: TabBarView(
                    children: [
                      _FoodTrucksTabContent(),
                      const EventBookingSelector(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// 🧩 Food Trucks Tab Content
class _FoodTrucksTabContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 12),
      children: [
        const PopularSearchesSection(),
        const SizedBox(height: 16),
        CuisineGridSection(
          onCuisineSelected: (selectedCuisine) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    FilteredTruckListPage(cuisine: selectedCuisine),
              ),
            );
          },
        ),
      ],
    );
  }
}
