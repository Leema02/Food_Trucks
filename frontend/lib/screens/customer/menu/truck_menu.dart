import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:myapp/core/services/menu_service.dart';
import 'package:myapp/screens/customer/menu/menu_card.dart';

class TruckMenuPage extends StatefulWidget {
  final String truckId;
  final String truckCity;
  final List<String>? activeSearchTerms;

  const TruckMenuPage({
    super.key,
    required this.truckId,
    required this.truckCity,
    this.activeSearchTerms,
  });

  @override
  State<TruckMenuPage> createState() => _TruckMenuPageState();
}

class _TruckMenuPageState extends State<TruckMenuPage> {
  List<dynamic> menuItems = [];
  List<dynamic> _allMenuItems = []; // Store all fetched items
  List<dynamic> _displayedMenuItems = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchAndFilterMenuItems();
  }

  Future<void> fetchAndFilterMenuItems() async { // Renamed for clarity
    setState(() {
      isLoading = true;
      errorMessage = '';
      _allMenuItems = [];
      _displayedMenuItems = [];
    });
    try {
      final response = await MenuService.getMenuItems(widget.truckId);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          _allMenuItems = data;
          _filterMenuItems(); // Apply filter after fetching
        } else {
          errorMessage = 'Menu data is not in the expected format.';
        }
      } else {
        errorMessage = 'Server Error: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage = 'Connection Error: $e';
    }
    setState(() => isLoading = false);
  }

  void _filterMenuItems() {
    if (widget.activeSearchTerms == null || widget.activeSearchTerms!.isEmpty) {
      // If no search terms, display all items
      _displayedMenuItems = List.from(_allMenuItems);
    } else {
      final searchTerms = widget.activeSearchTerms!.map((t) => t.toLowerCase()).toList();
      _displayedMenuItems = _allMenuItems.where((item) {
        if (item is Map<String, dynamic>) {
          final itemName = (item['name'] as String?)?.toLowerCase() ?? '';
          final itemDescription = (item['description'] as String?)?.toLowerCase() ?? '';
          final isVegan = item['isVegan'] as bool? ?? false;
          final isSpicy = item['isSpicy'] as bool? ?? false;
          // Potentially category as well
          // final category = (item['category'] as String?)?.toLowerCase() ?? '';

          // Item must satisfy ALL search terms to be included
          return searchTerms.every((term) {
            if (itemName.contains(term) || itemDescription.contains(term)) {
              return true;
            }
            if (term == 'vegan' && isVegan) return true;
            if (term == 'spicy' && isSpicy) return true;
            // if (category.contains(term)) return true;
            return false;
          });
        }
        return false; // Should not happen if API returns list of maps
      }).toList();
    }
    // No need for setState here if fetchAndFilterMenuItems calls this and then sets isLoading = false
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Truck Menu'),
        backgroundColor: Colors.orange,
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.orange),
            )
          : errorMessage.isNotEmpty
              ? Center(
                  child: Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                )
              : _displayedMenuItems.isEmpty
                  ? const Center(child: Text("No menu items found 😢"))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _displayedMenuItems.length,
                      itemBuilder: (context, index) {
                        return MenuCard(
                          item: _displayedMenuItems[index],
                          truckId: widget.truckId,
                          truckCity: widget.truckCity, // ✅ passed properly
                        );
                      },
                    ),
    );
  }
}
