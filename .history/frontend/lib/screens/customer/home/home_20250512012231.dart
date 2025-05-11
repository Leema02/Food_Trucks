import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import 'package:myapp/screens/customer/account/account.dart';
import 'package:myapp/screens/auth/widgets/home_page_custom_shape.dart';
import 'package:myapp/screens/customer/cart/cart.dart';
import 'package:myapp/core/constants/colors.dart';

import 'package:myapp/screens/customer/home/widgets/contact_drawer.dart';
import 'package:myapp/screens/customer/home/widgets/floating_star_button.dart';
import 'package:myapp/screens/customer/home/widgets/location_utils.dart';
import 'package:myapp/screens/customer/home/widgets/location_selector_sheet.dart';
import 'package:myapp/screens/customer/home/widgets/list_view_widget.dart';
import 'package:myapp/screens/customer/home/widgets/map_view_widget.dart';
import 'package:myapp/screens/customer/home/widgets/city_list_sheet.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: HomePage(),
  ));
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late final PageController _pageController;
  final MapController _mapController = MapController();

  String _currentCityName = '';
  Position? currentLocation;
  bool showMaps = false;
  bool selectedColor = true;
  int _currentIndex = 0;

  final List<Marker> _mapMarkers = [];

  final List<String> supportedCities = [
    'Ramallah',
    'Nablus',
    'Bethlehem',
    'Hebron',
    'Jericho',
    'Tulkarm',
    'Jenin',
    'Qalqilya',
    'Salfit',
    'Tubas',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0, keepPage: true);

    Geolocator.getCurrentPosition().then((position) async {
      final city =
          await getCorrectedCityName(position.latitude, position.longitude);
      setState(() {
        currentLocation = position;
        _currentCityName = city;
        showMaps = true;
      });
    });
  }

  Future<void> fetchPublicTrucks() async {
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
            const Text('Contact Food Truck',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.phone, color: Colors.green),
              title: const Text('Call Us'),
              onTap: () {
                Navigator.pop(context);
                print('Calling...');
              },
            ),
            ListTile(
              leading: const Icon(Icons.chat, color: Colors.blueAccent),
              title: const Text('Chat with Us'),
              onTap: () {
                Navigator.pop(context);
                print('Chatting...');
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
      title: const Text('Current location'),
      subtitle: const Text('Move to your current location'),
      trailing: const Icon(Icons.check_circle, color: Colors.red),
      onTap: () async {
        Navigator.pop(context);

        try {
          final freshPosition = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          );
          final detectedCity = await getCorrectedCityName(
              freshPosition.latitude, freshPosition.longitude);

          _mapController.move(
              LatLng(freshPosition.latitude, freshPosition.longitude), 15);

          setState(() {
            currentLocation = freshPosition;
            _currentCityName = detectedCity;
          });
        } catch (e) {
          print('Error $e');
        }
      },
    );
  }

  Widget _buildExploreServiceAreasTile(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.location_city),
      title: const Text('Explore our service areas'),
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
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                    ),
                    icon: const Icon(Icons.location_on),
                    label: Text(
                      _currentCityName.isEmpty
                          ? 'Choose Location'
                          : _currentCityName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 55.0, right: 8.0),
                    child: IconButton(
                      icon:
                          const Icon(Icons.phone_in_talk, color: Colors.white),
                      iconSize: 28,
                      onPressed: () =>
                          _scaffoldKey.currentState!.openEndDrawer(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
          child: Container(
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
                    'List View',
                    style: TextStyle(
                      color: selectedColor
                          ? AppColors.orangeColor
                          : AppColors.greyColor,
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
                    'Map View',
                    style: TextStyle(
                      color: !selectedColor
                          ? AppColors.orangeColor
                          : AppColors.greyColor,
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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
                  selectedLocation: _currentCityName,
                  header: _buildHeaderBar(),
                  onHeaderTap: _showLocationSelector,
                  onDrawerTap: () => _scaffoldKey.currentState!.openEndDrawer(),
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
                      : const LatLng(31.9, 35.2), // fallback
                  onHeaderTap: _showLocationSelector,
                  onDrawerTap: () => _scaffoldKey.currentState!.openEndDrawer(),
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
}
