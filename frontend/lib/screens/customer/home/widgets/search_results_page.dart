import 'dart:async';
import 'package:flutter/material.dart';
import 'package:myapp/screens/customer/home/widgets/truck_search_card.dart';
import '../../../../core/services/ai_search_service.dart';
import 'meal_search_card.dart';

class SearchResultsPage extends StatefulWidget {
  final List<Map<String, dynamic>> allTrucksWithMenus;
  final String selectedCity;

  const SearchResultsPage({
    super.key,
    required this.allTrucksWithMenus,
    required this.selectedCity,
  });

  @override
  _SearchResultsPageState createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  bool _isSearching = false;
  List<Map<String, dynamic>> _matchingTrucks = [];
  List<Map<String, dynamic>> _matchingMeals = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _performSearch(_searchController.text);
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _matchingTrucks = [];
        _matchingMeals = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    final searchTerms = await AISearchService.getProcessedSearchTerms(query);

    final filteredTrucks = <Map<String, dynamic>>{};
    final filteredMeals = <Map<String, dynamic>>[];
    final Set<String> matchedTruckIds = {};

    final termsToUse =
        searchTerms.isNotEmpty ? searchTerms : [query.toLowerCase()];

    for (final truck in widget.allTrucksWithMenus) {
      final truckId = truck['_id'];
      final truckName = (truck['truck_name'] as String?)?.toLowerCase() ?? '';
      final cuisineType =
          (truck['cuisine_type'] as String?)?.toLowerCase() ?? '';

      if (termsToUse.any(
          (term) => truckName.contains(term) || cuisineType.contains(term))) {
        if (!matchedTruckIds.contains(truckId)) {
          filteredTrucks.add(truck);
          matchedTruckIds.add(truckId);
        }
      }

      final menuItems = truck['menu_items'] as List<dynamic>? ?? [];
      for (var item in menuItems) {
        if (item is Map<String, dynamic>) {
          final itemName = (item['name'] as String?)?.toLowerCase() ?? '';
          final itemDescription =
              (item['description'] as String?)?.toLowerCase() ?? '';
          final isVegan = item['isVegan'] as bool? ?? false;
          final isSpicy = item['isSpicy'] as bool? ?? false;

          bool itemMatches = termsToUse.any((term) {
            if (itemName.contains(term) || itemDescription.contains(term)) {
              return true;
            }
            if (term == 'vegan' && isVegan) return true;
            if (term == 'spicy' && isSpicy) return true;
            return false;
          });

          if (itemMatches) {
            final augmentedMeal = Map<String, dynamic>.from(item);
            augmentedMeal['truck_id'] = truck['_id'];
            augmentedMeal['truck_name'] = truck['truck_name'];
            augmentedMeal['truck_city'] = truck['city'];
            augmentedMeal['_id'] = item['_id'];
            filteredMeals.add(augmentedMeal);

            if (!matchedTruckIds.contains(truckId)) {
              filteredTrucks.add(truck);
              matchedTruckIds.add(truckId);
            }
          }
        }
      }
    }

    setState(() {
      _matchingTrucks = filteredTrucks.toList();
      _matchingMeals = filteredMeals;
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      titleSpacing: 0,
      backgroundColor: Colors.white,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black87),
        onPressed: () => Navigator.pop(context),
      ),
      title: Padding(
        padding: const EdgeInsets.only(right: 16.0, top: 4, bottom: 4),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            children: [
              const SizedBox(width: 16),
              const Icon(Icons.search, color: Colors.grey),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  style: const TextStyle(fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'Search food trucks or meals...',
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
              if (_searchController.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    _searchController.clear();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isSearching) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              strokeWidth: 3,
              color: Colors.orange,
            ),
            const SizedBox(height: 20),
            Text(
              'Searching...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      );
    }

    if (_searchController.text.trim().isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.orange[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_rounded,
                size: 80,
                color: Colors.orange[300],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Discover Amazing Food',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Search for food trucks, meals, cuisines\nor specific ingredients',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
          ],
        ),
      );
    }

    if (_matchingMeals.isEmpty && _matchingTrucks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.orange[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.fastfood_rounded,
                size: 60,
                color: Colors.orange[300],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "No results found for '${_searchController.text}'",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Try different keywords or check spelling',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverAppBar(
          backgroundColor: Colors.grey[50],
          expandedHeight: 0,
          toolbarHeight: 0,
          pinned: true,
        ),
        if (_matchingMeals.isNotEmpty) ..._buildSectionHeader("Matching Meals"),
        if (_matchingMeals.isNotEmpty)
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final meal = _matchingMeals[index];
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 1, vertical: 1),
                  child: MealSearchCard(meal: meal),
                );
              },
              childCount: _matchingMeals.length,
            ),
          ),
        if (_matchingTrucks.isNotEmpty)
          ..._buildSectionHeader("Matching Trucks"),
        if (_matchingTrucks.isNotEmpty)
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final truck = _matchingTrucks[index];
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 1, vertical: 1),
                  child: TruckSearchCard(truck: truck),
                );
              },
              childCount: _matchingTrucks.length,
            ),
          ),
        const SliverToBoxAdapter(
          child: SizedBox(height: 24),
        ),
      ],
    );
  }

  List<Widget> _buildSectionHeader(String title) {
    return [
      SliverToBoxAdapter(
        child: Container(
          color: Colors.grey[50],
          padding: const EdgeInsets.only(top: 24, left: 24, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
      SliverToBoxAdapter(
        child: Divider(
          height: 1,
          thickness: 1,
          color: Colors.grey[200],
          indent: 24,
          endIndent: 24,
        ),
      ),
    ];
  }
}
