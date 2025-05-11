import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import 'package:myapp/screens/account/account.dart';
import 'package:myapp/screens/auth/widgets/home_page_custom_shape.dart';
import 'package:myapp/screens/customer/cart/cart.dart';
import 'package:myapp/core/constants/colors.dart';
import 'package:myapp/screens/customer/home/widgets/floating_star_button.dart';
import 'widgets/bottom_nav_bar.dart';
import 'widgets/contact_drawer.dart';
import 'widgets/floating_button.dart';
import 'widgets/location_utils.dart';
import 'widgets/location_selector_sheet.dart';
import 'widgets/list_view_widget.dart';
import 'widgets/map_view_widget.dart';
import 'widgets/city_list_sheet.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: HomePage(),
  ));
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late final PageController _pageController;
  final MapController _mapController = MapController();

  String? _currentCityName;
  Position? currentLocation;
  bool showMaps = false;
  bool selectedColor = true;

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
      final city =
          await getCorrectedCityName(position.latitude, position.longitude);
      setState(() => _currentCityName = city);
    });
  }

  void _onTabTapped(int index) {
    setState(() {
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
        currentLocationTile: _buildCurrentLocationTile(),
        exploreServiceAreasTile: _buildExploreServiceAreasTile(context),
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
        padding: const EdgeInsets.all(20.0),
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

  Widget _buildCurrentLocationTile() {
    return ListTile(
      leading: const Icon(Icons.my_location, color: Colors.red),
      title: const Text("Current location"),
      subtitle: const Text("Move to your current location"),
      trailing: const Icon(Icons.check_circle, color: Colors.red),
      onTap: () async {
        Navigator.pop(context);

        try {
          final freshPosition = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          );
          final city = await getCorrectedCityName(
              freshPosition.latitude, freshPosition.longitude);
          _mapController.move(
              LatLng(freshPosition.latitude, freshPosition.longitude), 15);
          setState(() {
            currentLocation = freshPosition;
            _currentCityName = city;
          });
        } catch (e) {
          print("Error: $e");
        }
      },
    );
  }

  Widget _buildExploreServiceAreasTile(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.location_city),
      title: const Text("Explore our service areas"),
      subtitle: const Text("See where we're operating"),
      onTap: () {
        Navigator.pop(context);
        Future.delayed(const Duration(milliseconds: 200), () {
          showCityListSheet(context, _mapController, _mapMarkers, (newCity) {
            setState(() {
              _currentCityName = newCity;
            });
          });
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingStarButton(onTap: () {}),
      bottomNavigationBar: HomeBottomNavBar(
        onTabSelected: _onTabTapped,
        currentIndex: _pageController.page?.toInt() ?? 0,
      ),
      endDrawer: ContactDrawer(
        onCallTap: () {
          Navigator.pop(context);
          _showContactOptions();
        },
        onChatTap: () {
          Navigator.pop(context);
          _showContactOptions();
        },
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          selectedColor
              ? ListViewWidget(
                  selectedLocation: _currentCityName ?? '',
                  header: _buildHeaderBar(),
                  onHeaderTap: _showLocationSelector,
                  onDrawerTap: () => _scaffoldKey.currentState?.openEndDrawer(),
                  cityName: '',
                )
              : MapViewWidget(
                  currentLocation: currentLocation,
                  mapController: _mapController,
                  markers: _mapMarkers,
                  header: _buildHeaderBar(),
                  center: currentLocation != null
                      ? LatLng(
                          currentLocation!.latitude, currentLocation!.longitude)
                      : const LatLng(31.9, 35.2),
                  onHeaderTap: _showLocationSelector,
                  onDrawerTap: () => _scaffoldKey.currentState?.openEndDrawer(),
                ),
          const Center(
            child: Text('Search Page (Coming Soon)',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          ),
          const Cart(),
          const Account(),
        ],
      ),
    );
  }

  Widget _buildHeaderBar() {
    return Column(
      children: [
        ClipPath(
          clipper: CustomShapeClipper(),
          child: Container(
            height: Platform.isIOS ? 200 : 160,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.orangeColor, AppColors.orangeLightColor],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Padding(
              padding: Platform.isIOS
                  ? const EdgeInsets.only(top: 50, left: 20, right: 20)
                  : const EdgeInsets.only(top: 30, left: 20, right: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    onPressed: _showLocationSelector,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.orangeColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                    ),
                    icon: const Icon(Icons.location_on),
                    label: Text(
                      _currentCityName ?? 'Choose Location',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 55.0, right: 8.0),
                    child: IconButton(
                      icon:
                          const Icon(Icons.phone_in_talk, color: Colors.white),
                      iconSize: 28,
                      onPressed: () =>
                          _scaffoldKey.currentState?.openEndDrawer(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  final List<String> supportedCities = [
    "Ramallah",
    "Nablus",
    "Bethlehem",
    "Hebron",
    "Jericho",
    "Tulkarm",
    "Jenin",
    "Qalqilya",
    "Salfit",
    "Tubas",
  ];

  void showCityListSheet(
    BuildContext context,
    MapController mapController,
    List<Marker> mapMarkers,
    Function(String) onCitySelected,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => CityListSheet(
        cities: supportedCities,
        onCitySelected: (cityName) async {
          Navigator.pop(context);
          final locations = await locationFromAddress('$cityName, Palestine');
          if (locations.isNotEmpty) {
            final loc = locations.first;
            final latLng = LatLng(loc.latitude, loc.longitude);

            mapMarkers.add(
              Marker(
                width: 40,
                height: 40,
                point: latLng,
                child: const Icon(Icons.location_on, color: Colors.orange),
              ),
            );

            mapController.move(latLng, 15);
            onCitySelected(cityName);
          }
        },
      ),
    );
  }
}
