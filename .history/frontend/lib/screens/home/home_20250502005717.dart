import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import 'package:myapp/screens/account/account.dart';
import 'package:myapp/screens/cart/cart.dart';
import 'package:myapp/core/constants/colors.dart';
import 'package:myapp/screens/home/widgets/home_main_container.dart';
import 'package:myapp/screens/home/widgets/floating_star_button.dart';
import 'package:myapp/screens/home/widgets/bottom_nav_bar.dart';
import 'package:myapp/screens/home/widgets/location_utils.dart';
import 'package:myapp/screens/home/widgets/contact_drawer.dart';
import 'package:myapp/screens/home/widgets/location_selector_sheet.dart';
import 'package:myapp/screens/home/widgets/map_view_widget.dart';
import 'package:myapp/screens/home/widgets/list_view_widget.dart';
import 'package:myapp/screens/home/widgets/header_bar.dart';
import 'package:myapp/screens/home/widgets/city_list_sheet.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

int _currentIndex = 0;

class HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late PageController _pageController;
  late final MapController _mapController = MapController();

  String? _currentCityName;
  bool selectedColor = true;
  Position? currentLocation;
  bool showMaps = false;

  final List<Marker> _mapMarkers = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0, keepPage: true);

    Geolocator.getCurrentPosition().then((position) async {
      setState(() {
        currentLocation = position;
        showMaps = true;
      });

      final corrected = await getCorrectedCityName(
        position.latitude,
        position.longitude,
      );
      setState(() => _currentCityName = corrected);
    });
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
      _pageController.jumpToPage(index);
    });
  }

  void _showLocationSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => LocationSelectorSheet(
        currentLocation: currentLocation,
        mapController: _mapController,
        onCitySelected: (city) => setState(() => _currentCityName = city),
      ),
    );
  }

  void _showContactOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Contact Food Truck",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.phone, color: Colors.green),
              title: const Text("Call Us"),
              onTap: () {
                Navigator.pop(context);
                print("Calling...");
              },
            ),
            ListTile(
              leading: const Icon(Icons.chat, color: Colors.blueAccent),
              title: const Text("Chat with Us"),
              onTap: () {
                Navigator.pop(context);
                print("Chatting...");
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;

    return Scaffold(
      key: _scaffoldKey,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingStarButton(onTap: () {}),
      bottomNavigationBar: HomeBottomNavBar(
        onTabSelected: _onTabTapped,
        currentIndex: _currentIndex,
      ),
      endDrawer: ContactDrawer(
        onCallTap: () {
          Navigator.pop(context);
          Future.delayed(
              const Duration(milliseconds: 200), () => _showContactOptions());
        },
        onChatTap: () {
          Navigator.pop(context);
          Future.delayed(
              const Duration(milliseconds: 200), () => _showContactOptions());
        },
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          selectedColor
              ? ListViewWidget(
                  cityName: _currentCityName ?? '',
                  onHeaderTap: _showLocationSelector,
                  onDrawerTap: () => _scaffoldKey.currentState?.openEndDrawer(),
                )
              : MapViewWidget(
                  mapController: _mapController,
                  markers: _mapMarkers,
                  currentLocation: currentLocation,
                  onHeaderTap: _showLocationSelector,
                  onDrawerTap: () => _scaffoldKey.currentState?.openEndDrawer(),
                ),
          const Center(
            child: Text('Search Page (Coming Soon)',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          ),
          Cart(),
          const Account(),
        ],
      ),
    );
  }
}
