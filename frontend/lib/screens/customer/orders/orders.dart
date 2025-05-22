import 'package:flutter/material.dart';
import 'package:myapp/screens/customer/orders/orders_list_tab.dart';
import 'bookings_list_tab.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("My Activity"),
          backgroundColor: Colors.orange,
          centerTitle: true,
          bottom: const TabBar(
            indicatorColor: Color.fromARGB(255, 0, 0, 0),
            labelColor: Color.fromARGB(255, 0, 0, 0), // active tab text color
            unselectedLabelColor:
                Color.fromARGB(179, 47, 47, 47), // inactive tab text color
            labelStyle: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            unselectedLabelStyle: TextStyle(
              fontSize: 14,
            ),
            tabs: [
              Tab(text: "Orders"),
              Tab(text: "Bookings"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            OrdersListTab(),
            BookingsListTab(),
          ],
        ),
      ),
    );
  }
}
