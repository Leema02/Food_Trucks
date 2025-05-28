import 'package:flutter/material.dart';
import 'package:myapp/screens/truckOwner/check%20Reviews/widgets/owner_menu_reviews_tab.dart';
import 'package:myapp/screens/truckOwner/check%20Reviews/widgets/owner_truck_reviews_tab.dart';
import 'package:easy_localization/easy_localization.dart';

class OwnerReviewsPage extends StatelessWidget {
  const OwnerReviewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("My Reviews".tr()),
          backgroundColor: const Color.fromARGB(255, 183, 153, 234),
          bottom: TabBar(
            tabs: [
              Tab(text: "truck_reviews".tr()),
              Tab(text: "menu_item_reviews".tr()),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            OwnerTruckReviewsTab(),
            OwnerMenuReviewsTab(),
          ],
        ),
      ),
    );
  }
}
