// home.dart
import 'package:flutter/material.dart';
import 'dart:async'; // For Timer (debouncing)
import 'dart:convert'; // For jsonEncode/Decode
import 'package:http/http.dart' as http; // For Gemini API call
import 'package:myapp/screens/customer/home/widgets/recommended_dishes_slider.dart';

// Make sure these paths are correct for your project structure
import '../../../core/services/menu_service.dart';
import '../../../core/services/truckOwner_service.dart';
import '../../../core/constants/supported_cities.dart';
import 'widgets/header_section.dart';
import 'widgets/search_filter_bar.dart'; // Updated path
import 'widgets/truck_card.dart';
import 'customer_map.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // All trucks with their menus for the selected city
  List<Map<String, dynamic>> _allTrucksWithMenusData = [];
  // Trucks to be displayed after filtering
  List<Map<String, dynamic>> _displayedTrucks = [];

  bool _isLoading = true;
  String _errorMessage = '';
  String _selectedCity = 'Qalqilya'; // Default city
  bool _isMapView = false;
  bool _isAISearching = false; // To show loading for AI processing
  List<String> _currentSearchTerms = [];

  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  // Gemini API Configuration
  static const String _geminiApiKey =
      'AIzaSyCsfzNXk_nP9V5my0gqNc5wV0-kPcPZ9YU'; // YOUR_GEMINI_API_KEY
  static final Uri _geminiUrl = Uri.parse(
    'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$_geminiApiKey', // Using gemini-pro as gemini-2.0-flash might not be public yet
  );

  @override
  void initState() {
    super.initState();
    _fetchTrucksAndMenus();
    _searchController.addListener(() {
      if (_debounce?.isActive ?? false) _debounce!.cancel();
      _debounce = Timer(const Duration(milliseconds: 700), () {
        _handleSearchQuery(_searchController.text);
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
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
          List<dynamic> parsedMenuItems = []; // Default to an empty list

          try {
            // 1. Await the http.Response from the MenuService
            final http.Response menuResponse = await MenuService.getMenuItems(
                truck['_id'] as String); // *** CORRECTED SERVICE CALL ***

            // 2. Check the status code and parse if successful
            if (menuResponse.statusCode == 200) {
              final decodedBody = jsonDecode(menuResponse.body);
              if (decodedBody is List) {
                // Ensure the decoded body is a List
                parsedMenuItems = decodedBody;
              } else {
                print(
                    "Warning: Menu items for truck ${truck['_id']} not in expected List format. Body: ${menuResponse.body}");
                // parsedMenuItems remains an empty list
              }
            } else if (menuResponse.statusCode == 404) {
              print(
                  "Menu not found for truck ${truck['_id']} (404). Assigning empty menu.");
              // parsedMenuItems remains an empty list, which is fine.
            } else {
              print(
                  "Error fetching menu for truck ${truck['_id']}: Status ${menuResponse.statusCode}, Body: ${menuResponse.body}");
              // parsedMenuItems remains an empty list
            }
          } catch (e) {
            print(
                "Exception during menu fetch or parse for truck ${truck['_id']}: $e");
            // parsedMenuItems remains an empty list
          }

          // 3. Augment truck data with the (potentially empty) parsed menu
          Map<String, dynamic> truckWithMenu = Map.from(truck);
          truckWithMenu['menu_items'] =
              parsedMenuItems; // THIS IS NOW GUARANTEED TO BE A List<dynamic>
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

  Future<String> _getAIProcessedSearchTerms(String rawQuery) async {
    if (rawQuery.trim().isEmpty) {
      setState(() {
        _currentSearchTerms = []; // <--- Clear terms if query is empty
      });
      return "";
    }
    setState(() => _isAISearching = true);

    // More specific prompt for Gemini
    final prompt = """
    Analyze the following user query for finding food trucks: "$rawQuery".
    Extract key food items, cuisine types, or dietary preferences (like vegan, spicy, gluten-free).
    Return a concise list of these terms, comma-separated.
    For example:
    - If query is "I want a spicy vegan burger", return "spicy, vegan, burger".
    - If query is "pizza places", return "pizza".
    - If query is "coffee and donuts", return "coffee, donuts".
    - If query is "healthy salads", return "healthy, salad".
    Keep it short and focused on searchable keywords.
    """;

    try {
      final response = await http.post(
        _geminiUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ]
        }),
      );

      setState(() => _isAISearching = false);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['candidates']?[0]?['content']?['parts']?[0]
            ?['text'] as String?;
        final termsString = content?.trim() ?? rawQuery.toLowerCase();
        // Update _currentSearchTerms here
        setState(() {
          _currentSearchTerms = termsString
              .split(',')
              .map((t) => t.trim().toLowerCase())
              .where((t) => t.isNotEmpty)
              .toList();
          if (_currentSearchTerms.isEmpty && rawQuery.trim().isNotEmpty) {
            // Fallback if AI gives nothing
            _currentSearchTerms.add(rawQuery.trim().toLowerCase());
          }
        });
        print("AI Processed Terms stored: $_currentSearchTerms");
        return termsString; // Still return the string for _performLocalSearch
      } else {
        print('Gemini API error: ${response.statusCode} - ${response.body}');
        final fallbackTermsString = rawQuery.toLowerCase();
        setState(() {
          _currentSearchTerms = fallbackTermsString
              .split(',')
              .map((t) => t.trim().toLowerCase())
              .where((t) => t.isNotEmpty)
              .toList();
          if (_currentSearchTerms.isEmpty && rawQuery.trim().isNotEmpty) {
            _currentSearchTerms.add(rawQuery.trim().toLowerCase());
          }
        });
        return fallbackTermsString;
      }
    } catch (e) {
      setState(() => _isAISearching = false);
      print('Error connecting to Gemini API: $e');
      return rawQuery.toLowerCase(); // Fallback
    }
  }

  Future<void> _handleSearchQuery(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _displayedTrucks = List.from(_allTrucksWithMenusData);
        _currentSearchTerms = [];
      });
      return;
    }

    final aiProcessedQuery = await _getAIProcessedSearchTerms(query);
    _performLocalSearch(aiProcessedQuery);
  }

  void _performLocalSearch(String processedQueryString) {
    // Parameter name clarified
    // Use _currentSearchTerms for filtering logic if it's populated,
    // otherwise, parse processedQueryString as before.
    // This ensures consistency. The primary source of terms is now _currentSearchTerms.

    List<String> termsToUse = List.from(_currentSearchTerms);

    if (termsToUse.isEmpty && _searchController.text.trim().isNotEmpty) {
      // This case should be rarer now as _getAIProcessedSearchTerms handles it
      termsToUse.add(_searchController.text.trim().toLowerCase());
    }

    if (termsToUse.isEmpty) {
      setState(() {
        _displayedTrucks = List.from(_allTrucksWithMenusData);
      });
      return;
    }

    final filteredTrucks = _allTrucksWithMenusData.where((truck) {
      final truckName = (truck['truck_name'] as String?)?.toLowerCase() ?? '';
      final cuisineType =
          (truck['cuisine_type'] as String?)?.toLowerCase() ?? '';
      final menuItems = truck['menu_items'] as List<dynamic>? ?? [];

      return termsToUse.every((term) {
        // <--- Use termsToUse
        if (truckName.contains(term) || cuisineType.contains(term)) {
          return true;
        }
        for (var item in menuItems) {
          if (item is Map<String, dynamic>) {
            final itemName = (item['name'] as String?)?.toLowerCase() ?? '';
            final itemDescription =
                (item['description'] as String?)?.toLowerCase() ?? '';
            final isVegan = item['isVegan'] as bool? ?? false;
            final isSpicy = item['isSpicy'] as bool? ?? false;

            if (itemName.contains(term) || itemDescription.contains(term)) {
              return true;
            }
            if (term == 'vegan' && isVegan) return true;
            if (term == 'spicy' && isSpicy) return true;
          }
        }
        return false;
      });
    }).toList();

    setState(() {
      _displayedTrucks = filteredTrucks;
    });
  }

  Widget _buildToggleButton(String label, bool value) {
    final isSelected = value == _isMapView;
    return GestureDetector(
      onTap: () async {
        if (value != _isMapView) {
          setState(() => _isMapView = value);
          if (value) {
            // Map View selected
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CustomerMapPage()),
            );
            // When returning from map view, set back to list view
            // Or handle this based on how CustomerMapPage returns
            setState(() => _isMapView = false);
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Colors
              .transparent, // isSelected ? Colors.orange.withOpacity(0.2) : Colors.transparent,
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
      body: Column(
        children: [
          HeaderSection(
            city: _selectedCity,
            supportedCities: supportedCities,
            onCityChange: (newCity) {
              if (newCity != _selectedCity) {
                setState(() => _selectedCity = newCity);
                _searchController.clear(); // Clear search when city changes
                _fetchTrucksAndMenus();
              }
            },
          ),
          SearchFilterBar(
            controller: _searchController,
            onChanged: (query) {
              // Debouncing is handled by the listener in initState
              // This onChanged can be used for immediate UI updates if needed,
              // but the main search logic is debounced.
            },
          ),
          // RecommendedDishesSlider(
          //   selectedCity: _selectedCity,
          // ),
          if (_isAISearching) // Show AI processing indicator
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.orange)),
                  SizedBox(width: 8),
                  Text("Thinking...", style: TextStyle(color: Colors.orange)),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 1)),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildToggleButton(
                      'List View', false), // false represents list view
                  SizedBox(
                      height: 20,
                      child: const VerticalDivider(
                          width: 1, thickness: 1, color: Colors.black26)),
                  _buildToggleButton(
                      'Map View', true), // true represents map view
                ],
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.orange))
                : _errorMessage.isNotEmpty
                    ? Center(child: Text(_errorMessage))
                    : _displayedTrucks.isEmpty
                        ? Center(
                            child: Text(_searchController.text.isEmpty
                                ? "No food trucks found in $_selectedCity 😢"
                                : "No matches for '${_searchController.text}'  શોધ😕"))
                        : ListView.builder(
                            itemCount: _displayedTrucks.length,
                            itemBuilder: (context, index) {
                              return TruckCard(
                                truck: _displayedTrucks[index],
                                activeSearchTerms: _currentSearchTerms,
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
