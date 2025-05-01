import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myapp/screens/home/widgets/bottom_nav_bar.dart';
import 'package:myapp/screens/home/widgets/end_drawer.dart';
import 'package:myapp/screens/home/widgets/floating_star_button.dart';
import 'package:myapp/screens/home/widgets/home_header.dart';
import 'package:myapp/screens/home/widgets/restaurant_list.dart';
import 'package:myapp/screens/home/widgets/view_toggle.dart';
import 'package:myapp/screens/account/account.dart';
import 'package:myapp/screens/cart/cart.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  String? _currentCityName;
  bool _showListView = true;
  Position? currentLocation;
  bool showMaps = false;

  final PageController _pageController = PageController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    try {
      // Implement your location initialization logic here
    } catch (e) {
      print("Error getting location: $e");
      setState(() => _currentCityName = "Unknown Location");
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
    _pageController.jumpToPage(index);
  }

  void _toggleView(bool showListView) {
    setState(() => _showListView = showListView);
  }

  void _updateCity(String city) {
    setState(() => _currentCityName = city);
  }

  void _showLocationSelection(BuildContext context) {
    // Implement your location selection dialog
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      floatingActionButton: const FloatingStarButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: HomeBottomNavBar(
        currentIndex: _currentIndex,
        onTabSelected: _onTabTapped,
      ),
      endDrawer: const HomeEndDrawer(),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          // Home Tab
          Column(
            children: [
              HomeHeader(
                city: _currentCityName,
                onLocationPressed: () => _showLocationSelection(context),
                onMenuPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
                showLocationButton: !_showListView,
              ),
              ViewToggle(
                showListView: _showListView,
                onToggle: _toggleView,
              ),
              Expanded(
                child: _showListView
                    ? RestaurantList(selectedLocation: _currentCityName ?? '')
                    : _buildMapView(),
              ),
            ],
          ),
          // Search Tab
          _buildSearchPage(),
          // Cart Tab
          const Cart(),
          // Account Tab
          const Account(),
        ],
      ),
    );
  }

  Widget _buildMapView() {
    // Implement your map view here
    return Center(
        child: Text("Map View for ${_currentCityName ?? 'unknown location'}"));
  }

  Widget _buildSearchPage() {
    return const Center(
      child: Text(
        'Search Page',
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
    );
  }
}
