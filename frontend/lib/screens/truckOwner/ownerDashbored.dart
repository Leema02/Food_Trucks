import 'package:flutter/material.dart';
import 'package:myapp/screens/auth/widgets/auth_background.dart';
import 'package:myapp/screens/truckOwner/manageTrucks/addTruck.dart';
//import 'package:myapp/screens/truckOwner/manageMenu.dart';
import 'package:myapp/screens/truckOwner/manageTrucks/viewTrucks.dart';
import 'package:myapp/screens/truckOwner/owner_orders.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: TruckOwnerDashboard(),
  ));
}

class TruckOwnerDashboard extends StatelessWidget {
  const TruckOwnerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset('assets/image/truckLogo.png', height: 80),
                    const Icon(Icons.notifications_none,
                        size: 28, color: Colors.deepOrange),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Welcome, Truck Owner!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildInfoCard(
                        'Total Orders', '0', Icons.shopping_cart_outlined),
                    _buildInfoCard('Bookings', '0', Icons.calendar_today),
                    _buildInfoCard('Reviews', '0', Icons.star_outline),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Quick Actions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.3,
                    children: [
                      _buildActionButton(
                        context,
                        'Add Truck',
                        Icons.add_business,
                        Colors.orange,
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AddTruckPage()),
                        ),
                      ),
                      _buildActionButton(
                        context,
                        'View Trucks',
                        Icons.directions_bus,
                        Colors.deepOrange,
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ViewTrucksScreen()),
                        ),
                      ),
                      //   _buildActionButton(
                      //     context,
                      //     'Manage Menu',
                      //     Icons.restaurant_menu,
                      //     Colors.brown,
                      //     // onPressed: () => Navigator.push(
                      //     //   context,
                      //     //   MaterialPageRoute(
                      //     //       builder: (context) => const ManageMenuPage()),
                      //     // ),
                      //  onPressed: () {},
                      //   ),
                      _buildActionButton(
                        context,
                        'View Orders',
                        Icons.receipt_long,
                        Colors.teal,
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const OwnerOrdersPage()),
                        ),
                      ),
                      _buildActionButton(
                        context,
                        'Event Bookings',
                        Icons.event,
                        Colors.amber,
                        onPressed: () {},
                      ),
                      _buildActionButton(
                        context,
                        'Reviews',
                        Icons.rate_review,
                        Colors.indigo,
                        onPressed: () {},
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String count, IconData icon) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 30, color: Colors.deepOrange),
          const SizedBox(height: 8),
          Text(count,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(title, style: const TextStyle(fontSize: 12))
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color, {
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: color,
        shadowColor: Colors.orangeAccent,
        elevation: 4,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24),
          const SizedBox(height: 10),
          Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
