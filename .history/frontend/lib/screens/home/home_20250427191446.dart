import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';

import 'package:myapp/screens/account/account.dart';
import 'package:myapp/screens/cart/cart.dart';
import 'package:myapp/core/constants/colors.dart';
import 'package:myapp/screens/home/widgets/home_main_container.dart';
import 'package:myapp/screens/home/widgets/floating_star_button.dart';
import 'package:myapp/screens/home/widgets/end_drawer.dart';
import 'package:myapp/screens/home/widgets/bottom_nav_bar.dart';
import 'package:myapp/screens/auth/widgets/home_page_custom_shape.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: HomePage(),
  ));
}

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
  final Map<String, String> cityCorrections = {
    // North
    "Asira ash-Shamaliya": "Nablus",
    "Beit Dajan": "Nablus",
    "Askar Camp": "Nablus",
    "Balata Camp": "Nablus",
    "Huwara": "Nablus",
    "Jenin Camp": "Jenin",
    "Zababdeh": "Jenin",
    "Tubas": "Tubas",
    "Tulkarm": "Tulkarm",
    "Anabta": "Tulkarm",
    "Qalqilya": "Qalqilya",
    "Salfit": "Salfit",

    // Central
    "Ramallah": "Ramallah",
    "Al-Bireh": "Ramallah",
    "Birzeit": "Ramallah",
    "Beituniya": "Ramallah",
    "Jericho": "Jericho",
    "Old City": "Jerusalem",
    "Al-Ram": "Jerusalem",
    "Bethany": "Jerusalem",

    // South
    "Hebron": "Hebron",
    "Halhul": "Hebron",
    "Yatta": "Hebron",
    "Dura": "Hebron",
    "Bethlehem": "Bethlehem",
    "Beit Jala": "Bethlehem",
    "Beit Sahour": "Bethlehem",
    "Dheisheh Camp": "Bethlehem",
  };

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

      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          final Placemark place = placemarks.first;
          String detectedCity =
              place.locality ?? place.administrativeArea ?? "Unknown";
          String correctedCity = cityCorrections[detectedCity] ?? detectedCity;
          setState(() {
            _currentCityName = correctedCity;
          });
        } else {
          setState(() {
            _currentCityName = "Unknown Location";
          });
        }
      } catch (e) {
        print("Error getting location: $e");
        setState(() {
          _currentCityName = "Unknown Location";
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
      _pageController.jumpToPage(index);
    });
  }

  void _showLocationSelectionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Center(
              child: Container(
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Choose your location",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            const SizedBox(height: 16),
            _buildCurrentLocationTile(),
            const Divider(height: 32, thickness: 1),
            _buildExploreServiceAreasTile(context),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderBar({required bool useButton}) {
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
                  ? const EdgeInsets.only(top: 50.0, left: 20, right: 20)
                  : const EdgeInsets.only(top: 30.0, left: 20, right: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (useButton) ...[
                    ElevatedButton.icon(
                      onPressed: () => _showLocationSelectionSheet(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.orangeColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                      ),
                      icon: const Icon(Icons.location_on),
                      label: const Text(
                        "Choose Location",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ] else ...[
                    Text(
                      _currentCityName ?? '',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                      ),
                    ),
                  ],
                  Padding(
                    padding: const EdgeInsets.only(bottom: 55.0, right: 8.0),
                    child: IconButton(
                      icon: const Icon(Icons.tune, color: Colors.white),
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
          child: _buildViewToggleButtons(),
        ),
      ],
    );
  }

  Widget _buildHomePage(Size media) {
    return selectedColor ? _buildListViewPage(media) : _buildMapViewPage(media);
  }

  Widget _buildSearchPage() {
    return Center(
      child: Text(
        'Search Page (Coming Soon)',
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildListViewPage(Size media) => Column(
        children: [
          _buildHeaderBar(useButton: false),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child:
                  HomeMainContainer(selectedLocation: _currentCityName ?? ''),
            ),
          ),
        ],
      );

  Widget _buildMapViewPage(Size media) => Stack(
        children: [
          // Map view itself
          Positioned.fill(
            child: showMaps
                ? FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: LatLng(
                        currentLocation!.latitude,
                        currentLocation!.longitude,
                      ),
                      initialZoom: 15,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.myapp',
                      ),
                      MarkerLayer(markers: _mapMarkers),
                    ],
                  )
                : const Center(child: CircularProgressIndicator()),
          ),

          // 🔥 Header still on top
          _buildHeaderBar(useButton: true),
        ],
      );

  Widget _buildViewToggleButtons() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade400,
            blurRadius: 8,
            spreadRadius: 1,
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GestureDetector(
            onTap: () => setState(() => selectedColor = true),
            child: Text(
              "List View",
              style: TextStyle(
                color:
                    selectedColor ? AppColors.orangeColor : AppColors.greyColor,
                fontWeight: FontWeight.w400,
                fontSize: 16,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: VerticalDivider(color: Colors.black),
          ),
          GestureDetector(
            onTap: () => setState(() => selectedColor = false),
            child: Text(
              "Map View",
              style: TextStyle(
                color:
                    selectedColor ? AppColors.greyColor : AppColors.orangeColor,
                fontWeight: FontWeight.w400,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentLocationTile() {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.red.shade100,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.my_location, color: Colors.red),
      ),
      title: const Text(
        "Current location",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: const Text("Move to your current location"),
      trailing: const Icon(Icons.check_circle, color: Colors.red),
      onTap: () async {
        Navigator.pop(context); // ✅ Close the bottom sheet immediately

        // ✅ Instantly move map to the last known location first
        if (currentLocation != null) {
          _mapController.move(
            LatLng(currentLocation!.latitude, currentLocation!.longitude),
            15,
          );
        }

        // ✅ Meanwhile, in background, get fresh updated location
        try {
          Position freshPosition = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          );

          // Move to fresh location (more accurate) as soon as fetched
          _mapController.move(
            LatLng(freshPosition.latitude, freshPosition.longitude),
            15,
          );

          // Get fresh city name
          List<Placemark> placemarks = await placemarkFromCoordinates(
            freshPosition.latitude,
            freshPosition.longitude,
          );

          if (placemarks.isNotEmpty) {
            final Placemark place = placemarks.first;
            String detectedCity =
                place.locality ?? place.administrativeArea ?? "Unknown";

            setState(() {
              currentLocation = freshPosition; // 🧡 Save the new fresh location
              _currentCityName = detectedCity; // Update city name
            });
          } else {
            setState(() {
              _currentCityName = "Unknown Location";
            });
          }
        } catch (e) {
          print("Error fetching updated location: $e");
          // If fails, keep last location
        }
      },
    );
  }

  Widget _buildExploreServiceAreasTile(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.location_city, color: Colors.black),
      title: const Text(
        "Explore our service areas",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: const Text("See where we're operating"),
      onTap: () {
        Navigator.pop(context); // close first bottom sheet
        Future.delayed(const Duration(milliseconds: 200), () {
          _showCitiesList(context); // open cities list
        });
      },
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
      endDrawer: EndDrawer(parentContext: context),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildHomePage(media),
          _buildSearchPage(),
          Cart(),
          const Account(),
        ],
      ),
    );
  }

  void _moveToUserLocation() {
    if (currentLocation != null) {
      _mapController.move(
        LatLng(currentLocation!.latitude, currentLocation!.longitude),
        15, // zoom level
      );
    }
  }

  void _showCitiesList(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            "Select a city:",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildCityTile("Ramallah"),
          _buildCityTile("Nablus"),
          _buildCityTile("Hebron"),
          _buildCityTile("Bethlehem"),
          _buildCityTile("Jenin"),
          _buildCityTile("Tulkarm"),
          _buildCityTile("Qalqilya"),
          _buildCityTile("Salfit"),
          _buildCityTile("Tubas"),
          _buildCityTile("Jericho"),
        ],
      ),
    );
  }

  Widget _buildCityTile(String cityName) {
    return ListTile(
      title: Text(cityName),
      trailing: const Icon(Icons.location_on, color: Colors.orange),
      onTap: () {
        Navigator.pop(context); // close bottom sheet
        _moveMapTo(cityName); // move map to selected city ✅
        setState(() {
          _currentCityName =
              cityName; // update the selected location on the header
        });
      },
    );
  }

  void _moveMapTo(String locationName) async {
    try {
      String fullQuery = "$locationName, Palestine";
      List<Location> locations = await locationFromAddress(fullQuery);

      if (locations.isNotEmpty) {
        final loc = locations.first;
        final latLng = LatLng(loc.latitude, loc.longitude);

        _mapMarkers.add(
          Marker(
            width: 40,
            height: 40,
            point: latLng,
            child: const Icon(
              Icons.location_on,
              color: Colors.orange,
              size: 36,
            ),
          ),
        );

        // Move map center
        _mapController.move(latLng, 15);

        setState(() {
          currentLocation = Position(
            latitude: latLng.latitude,
            longitude: latLng.longitude,
            timestamp: DateTime.now(),
            accuracy: 1.0,
            altitude: 0.0,
            heading: 0.0,
            speed: 0.0,
            speedAccuracy: 0.0,
            altitudeAccuracy: 1.0,
            headingAccuracy: 1.0,
          );
        });
      }
    } catch (e) {
      print("Location lookup failed: $e");
    }
  }
}
