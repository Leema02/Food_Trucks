import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:myapp/screens/customer/home/widgets/recommended_dishes_slider.dart';
import 'package:myapp/screens/customer/home/widgets/search_results_page.dart';

import '../../../core/services/menu_service.dart';
import '../../../core/services/truckOwner_service.dart';
import '../../../core/constants/supported_cities.dart';
import 'widgets/header_section.dart';
import 'widgets/search_filter_bar.dart';
import 'widgets/truck_card.dart';
import 'customer_map.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Map<String, dynamic>> _allTrucksWithMenusData = [];
  List<Map<String, dynamic>> _displayedTrucks = [];

  bool _isLoading = true;
  String _errorMessage = '';
  String _selectedCity = 'Qalqilya';
  bool _isMapView = false;

  @override
  void initState() {
    super.initState();
    _fetchTrucksAndMenus();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _fetchTrucksAndMenus() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _allTrucksWithMenusData = [];
      _displayedTrucks = [];
    });

    try {
      final trucksData =
      await TruckOwnerService.getPublicTrucks(city: _selectedCity);
      List<Map<String, dynamic>> tempTrucksWithMenus = [];

      for (var truck in trucksData) {
        if (truck is Map<String, dynamic> && truck.containsKey('_id')) {
          List<dynamic> parsedMenuItems = [];
          try {
            final http.Response menuResponse = await MenuService.getMenuItems(truck['_id'] as String);
            if (menuResponse.statusCode == 200) {
              final decodedBody = jsonDecode(menuResponse.body);
              if (decodedBody is List) {
                parsedMenuItems = decodedBody;
              } else {
                print("Warning: Menu items for truck ${truck['_id']} not in expected List format.");
              }
            } else if (menuResponse.statusCode == 404) {
            } else {
              print("Error fetching menu for truck ${truck['_id']}: Status ${menuResponse.statusCode}");
            }
          } catch (e) {
            print("Exception during menu fetch for truck ${truck['_id']}: $e");
          }
          Map<String, dynamic> truckWithMenu = Map.from(truck);
          truckWithMenu['menu_items'] = parsedMenuItems;
          tempTrucksWithMenus.add(truckWithMenu);
        }
      }
      setState(() {
        _allTrucksWithMenusData = tempTrucksWithMenus;
        _displayedTrucks = List.from(_allTrucksWithMenusData);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Failed to load trucks: ${e.toString()}";
        _isLoading = false;
      });
    }
  }

  void _navigateToSearch() {
    if (_isLoading) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please wait, data is loading...")),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchResultsPage(
          allTrucksWithMenus: _allTrucksWithMenusData,
          selectedCity: _selectedCity,
        ),
      ),
    );
  }

  Widget _buildToggleButton(String label, bool value) {
    final isSelected = value == _isMapView;
    return GestureDetector(
      onTap: () async {
        if (value != _isMapView) {
          setState(() => _isMapView = value);
          if (value) {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CustomerMapPage()),
            );
            setState(() => _isMapView = false);
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.orange : Colors.grey,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        title: const Text('Food Trucks Near You'),
        backgroundColor: Colors.orange,
        centerTitle: true,
        elevation: 0,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: HeaderSection(
              city: _selectedCity,
              supportedCities: supportedCities,
              onCityChange: (newCity) {
                if (newCity != _selectedCity) {
                  setState(() => _selectedCity = newCity);
                  _fetchTrucksAndMenus();
                }
              },
            ),
          ),
          SliverToBoxAdapter(
            child: SearchFilterBar(
              onTap: _navigateToSearch,
            ),
          ),
          SliverToBoxAdapter(
            child: RecommendedDishesSlider(
              selectedCity: _selectedCity,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 1))],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildToggleButton('List View', false),
                      const SizedBox(
                        height: 20,
                        child: VerticalDivider(width: 1, thickness: 1, color: Colors.black26),
                      ),
                      _buildToggleButton('Map View', true),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_isLoading)
            const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: Colors.orange)))
          else if (_errorMessage.isNotEmpty)
            SliverFillRemaining(child: Center(child: Text(_errorMessage)))
          else if (_displayedTrucks.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Text("No food trucks found in $_selectedCity 😢"),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    return TruckCard(
                      truck: _displayedTrucks[index],
                      activeSearchTerms: const [],
                    );
                  },
                  childCount: _displayedTrucks.length,
                ),
              ),
        ],
      ),
    );
  }
}
