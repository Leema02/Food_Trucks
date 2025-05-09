import 'package:flutter/material.dart';
import 'home/home.dart';
import 'explore/explore.dart';
import 'orders/orders.dart';
import 'cart/cart.dart';
import 'account/account.dart';

class CustomerMainContainer extends StatefulWidget {
  const CustomerMainContainer({super.key});

  @override
  State<CustomerMainContainer> createState() => _CustomerMainContainerState();
}

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: CustomerMainContainer(),
  ));
}

class _CustomerMainContainerState extends State<CustomerMainContainer> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const Home(),
    const ExplorePage(),
    const OrdersPage(),
    const CartPage(),
    const AccountPage(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
        elevation: 10,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: 'Near Me',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}
