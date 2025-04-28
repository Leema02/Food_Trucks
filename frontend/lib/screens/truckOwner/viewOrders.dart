// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:myapp/core/services/truckOwner_service.dart';
// import 'package:myapp/screens/auth/widgets/auth_background.dart';

// class ViewOrdersPage extends StatefulWidget {
//   const ViewOrdersPage({super.key});

//   @override
//   State<ViewOrdersPage> createState() => _ViewOrdersPageState();
// }

// class _ViewOrdersPageState extends State<ViewOrdersPage> {
//   List<dynamic> orders = [];
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     fetchOrders();
//   }

//   Future<void> fetchOrders() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('token') ?? '';

//       final response = await TruckOwnerService.getMyOrders(token);
//       if (response.statusCode == 200) {
//         setState(() {
//           orders = jsonDecode(response.body);
//           isLoading = false;
//         });
//       } else {
//         print('Failed to fetch orders: ${response.body}');
//       }
//     } catch (e) {
//       print('Error fetching orders: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: AuthBackground(
//         child: SafeArea(
//           child: isLoading
//               ? const Center(child: CircularProgressIndicator())
//               : orders.isEmpty
//                   ? const Center(child: Text('No orders found.'))
//                   : ListView.builder(
//                       padding: const EdgeInsets.all(16.0),
//                       itemCount: orders.length,
//                       itemBuilder: (context, index) {
//                         final order = orders[index];
//                         return Card(
//                           margin: const EdgeInsets.symmetric(vertical: 8),
//                           shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(16)),
//                           elevation: 4,
//                           child: ListTile(
//                             title: Text("Order #${order['_id']}"),
//                             subtitle: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 const SizedBox(height: 8),
//                                 Text("Customer: ${order['customer_name']}"),
//                                 Text("Items: ${order['items'].length}"),
//                                 Text("Total: \$${order['total']}"),
//                                 Text("Status: ${order['status']}"),
//                                 Text("Date: ${order['createdAt']}"),
//                               ],
//                             ),
//                             trailing:
//                                 Icon(Icons.fastfood, color: Colors.orange[800]),
//                           ),
//                         );
//                       },
//                     ),
//         ),
//       ),
//     );
//   }
// }
