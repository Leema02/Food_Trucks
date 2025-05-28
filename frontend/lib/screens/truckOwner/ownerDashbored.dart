import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:myapp/screens/account/account.dart';
import 'package:myapp/screens/auth/widgets/auth_background.dart';
import 'package:myapp/screens/truckOwner/check%20Reviews/owner_reviews_page.dart';
import 'package:myapp/screens/truckOwner/manage%20bookings/bookings_page.dart';
import 'package:myapp/screens/truckOwner/manageAvailability/availability_calendar.dart';
import 'package:myapp/screens/truckOwner/manageTrucks/addTruck.dart';
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
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.language,
                              color: Colors.deepOrange),
                          onPressed: () {
                            final currentLocale = context.locale;
                            final newLocale = currentLocale.languageCode == 'en'
                                ? const Locale('ar')
                                : const Locale('en');
                            context.setLocale(newLocale);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.notifications_none,
                              size: 28, color: Colors.deepOrange),
                          onPressed: () {
                            // Handle notification click here
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.menu,
                              size: 28, color: Colors.deepOrange),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const AccountPage(role: 'truck owner'),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'welcome_owner'.tr(),
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
                        'total_orders'.tr(), '0', Icons.shopping_cart_outlined),
                    _buildInfoCard('bookings'.tr(), '0', Icons.calendar_today),
                    _buildInfoCard('reviews'.tr(), '0', Icons.star_outline),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'quick_actions'.tr(),
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
                        'add_truck'.tr(),
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
                        'view_trucks'.tr(),
                        Icons.directions_bus,
                        Colors.deepOrange,
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ViewTrucksScreen()),
                        ),
                      ),
                      _buildActionButton(
                        context,
                        'manage_availability'.tr(),
                        Icons.calendar_month,
                        Colors.deepPurple,
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AvailabilityCalendar(),
                          ),
                        ),
                      ),
                      _buildActionButton(
                        context,
                        'view_orders'.tr(),
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
                        'event_bookings'.tr(),
                        Icons.event,
                        Colors.amber,
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const OwnerBookingsPage()),
                        ),
                      ),
                      _buildActionButton(
                        context,
                        'reviews'.tr(),
                        Icons.rate_review,
                        Colors.indigo,
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const OwnerReviewsPage()),
                        ),
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
