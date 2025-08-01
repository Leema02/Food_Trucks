import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../../core/services/order_service.dart';
import '../../../../core/services/review_service.dart';
import '../../../../core/services/truckOwner_service.dart';
import '../../../../core/services/menu_service.dart';
import 'recommendation_card.dart';

const Color ffPrimaryColorSlider = Colors.orange;
const double ffSizeMdSlider = 16.0;
const double ffSizeSmCard = 8.0;

class RecommendedDishesSlider extends StatefulWidget {
  final String selectedCity;

  const RecommendedDishesSlider({
    super.key,
    required this.selectedCity,
  });

  @override
  State<RecommendedDishesSlider> createState() =>
      _RecommendedDishesSliderState();
}

class _RecommendedDishesSliderState extends State<RecommendedDishesSlider> {
  List<Map<String, dynamic>> _recommendedItems = [];
  bool _isLoading = true;
  String _errorMessage = '';
  List<Map<String, dynamic>> _allAvailableMenusWithTruckInfo = [];
  @override
  void initState() {
    super.initState();
    print("[SLIDER_DEBUG] initState CALLED for RecommendedDishesSlider.");
    _fetchRecommendations();
  }

  @override
  void didUpdateWidget(covariant RecommendedDishesSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    print(
        "[SLIDER_DEBUG] didUpdateWidget CALLED. Old city: ${oldWidget.selectedCity}, New city: ${widget.selectedCity}");
    if (oldWidget.selectedCity != widget.selectedCity) {
      _fetchRecommendations();
    }
  }

  Future<List<Map<String, dynamic>>> _fetchUserReviews() async {
    try {
      final List<dynamic> reviewsRaw =
          await ReviewService.fetchMyMenuItemReviews();
      // Convert List<dynamic> to List<Map<String, dynamic>>
      return reviewsRaw
          .map((review) => review as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print("[SLIDER_DEBUG] Error fetching user reviews: $e");
      return []; // Return empty list on error
    }
  }

  Future<void> _fetchRecommendations() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _recommendedItems = [];
      _allAvailableMenusWithTruckInfo = [];
    });
    print(
        "[SLIDER_DEBUG] Starting _fetchRecommendations for city: ${widget.selectedCity}");

    try {
      // 1. Fetch user's past orders
      // IMPORTANT: If OrderService.getMyOrders() requires a token, provide it.
      // Using the one from your snippet which doesn't take a token.
      final http.Response ordersResponse = await OrderService.getMyOrders();
      List<dynamic> pastOrders = [];
      if (ordersResponse.statusCode == 200) {
        pastOrders = jsonDecode(ordersResponse.body) as List<dynamic>? ?? [];
      } else {
        print(
            "[SLIDER_DEBUG] Error fetching orders: ${ordersResponse.statusCode} - ${ordersResponse.body}");
      }
      print("[SLIDER_DEBUG] Past Orders Count: ${pastOrders.length}");

      List<String> pastOrderNames = pastOrders
          .expand((order) {
            return (order['items'] as List<dynamic>? ?? [])
                .map((item) => item['name'] as String);
          })
          .toSet()
          .take(10)
          .toList();
      print("[SLIDER_DEBUG] Past Order Names for AI: $pastOrderNames");

      final List<Map<String, dynamic>> userReviews = await _fetchUserReviews();
      print("[SLIDER_DEBUG] User Reviews Count: ${userReviews.length}");

      // 2. Fetch trucks
      final List<dynamic> trucksInCity =
          await TruckOwnerService.getPublicTrucks(city: widget.selectedCity);
      print(
          "[SLIDER_DEBUG] Trucks in ${widget.selectedCity}: ${trucksInCity.length}");

      // 3. Fetch menus and augment
      for (var truckData in trucksInCity) {
        if (truckData is Map<String, dynamic> && truckData.containsKey('_id')) {
          final String truckId = truckData['_id'] as String;
          final String truckName =
              truckData['truck_name'] as String? ?? 'Unknown Truck';
          // print("[SLIDER_DEBUG] Fetching menu for truck: $truckName ($truckId)");
          final http.Response menuResponse =
              await MenuService.getMenuItems(truckId);
          if (menuResponse.statusCode == 200) {
            final List<dynamic> truckMenuItems =
                jsonDecode(menuResponse.body) as List<dynamic>? ?? [];
            for (var menuItem in truckMenuItems) {
              if (menuItem is Map<String, dynamic>) {
                menuItem['truck_id_for_recommendation'] = truckId;
                menuItem['truck_name_for_recommendation'] = truckName;
                menuItem['truck_city_for_recommendation'] = widget.selectedCity;
                _allAvailableMenusWithTruckInfo.add(menuItem);
              }
            }
          } else {
            // print("[SLIDER_DEBUG] Failed to fetch menu for $truckName: ${menuResponse.statusCode}");
          }
        }
      }
      print(
          "[SLIDER_DEBUG] Total available menu items collected: ${_allAvailableMenusWithTruckInfo.length}");

      if (_allAvailableMenusWithTruckInfo.isEmpty) {
        if (!mounted) return;
        setState(() {
          _errorMessage =
              "No menus in ${widget.selectedCity} to get recommendations from.";
          _isLoading = false;
        });
        print("[SLIDER_DEBUG] $_errorMessage");
        return;
      }

      // 4. Get AI recommendations
      final String recommendationsJson = await _getAIRecommendations(
          pastOrderNames, userReviews, _allAvailableMenusWithTruckInfo);
      print("[SLIDER_DEBUG] AI Raw Recommendation JSON: $recommendationsJson");
      if (!mounted) return;

      List<dynamic> decodedRecommendations = [];
      try {
        decodedRecommendations = jsonDecode(recommendationsJson);
      } catch (e) {
        print(
            "[SLIDER_DEBUG] Failed to decode AI recommendations: $e. Response was: $recommendationsJson");
        _errorMessage = "AI recommendations format error.";
        setState(() => _isLoading = false);
        return;
      }

      List<Map<String, dynamic>> tempRecommendedFullItems = [];
      for (var recIdOrName in decodedRecommendations) {
        final String searchTerm =
            (recIdOrName is Map && recIdOrName.containsKey('menu_id'))
                ? recIdOrName['menu_id'] as String
                : recIdOrName.toString();

        final foundItem = _allAvailableMenusWithTruckInfo.firstWhere(
          (item) =>
              (item['_id'] as String?) == searchTerm ||
              (item['name'] as String?)?.toLowerCase() ==
                  searchTerm.toLowerCase(),
          orElse: () => <String, dynamic>{},
        );

        if (foundItem.isNotEmpty &&
            !tempRecommendedFullItems
                .any((existing) => existing['_id'] == foundItem['_id'])) {
          tempRecommendedFullItems.add(foundItem);
        }
      }
      print(
          "[SLIDER_DEBUG] Processed AI recommendations into full items: ${tempRecommendedFullItems.length}");
      setState(
          () => _recommendedItems = tempRecommendedFullItems.take(5).toList());
    } catch (e, stackTrace) {
      if (!mounted) return;
      print("[SLIDER_DEBUG] CRITICAL ERROR in _fetchRecommendations: $e");
      print("[SLIDER_DEBUG] StackTrace: $stackTrace");
      setState(() => _errorMessage = "Failed to load recommendations.");
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
      print(
          "[SLIDER_DEBUG] _fetchRecommendations finished. Loading: $_isLoading, Error: $_errorMessage, Items: ${_recommendedItems.length}");
    }
  }

  Future<String> _getAIRecommendations(
      List<String> pastOrderNames,
      List<Map<String, dynamic>> userReviews,
      List<Map<String, dynamic>> availableMenuItems) async {
    print(
        "[SLIDER_DEBUG] Getting AI recommendations. Past orders: ${pastOrderNames.length}, Available menus: ${availableMenuItems.length}");
    const apiKey = 'AIzaSyCsfzNXk_nP9V5my0gqNc5wV0-kPcPZ9YU'; // TODO: Replace
    final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=$apiKey');

    final summarizedAvailableItems = availableMenuItems
        .map((item) => {
              'menu_id': item['_id'], 'name': item['name'],
              // 'category': item['category'], // Optional: keep prompt smaller
              'truck_name': item['truck_name_for_recommendation'],
            })
        .toList();

    // Summarize user reviews to include in the prompt
    final summarizedUserReviews = userReviews
        .map((review) {
          // Extract menu item name from nested structure
          String menuItemName = 'Unknown Item';
          if (review['menu_item_id'] is Map &&
              review['menu_item_id']['name'] != null) {
            menuItemName = review['menu_item_id']['name'];
          }
          return {
            'item_name': menuItemName,
            'rating': review['rating'],
            'comment_summary': (review['comment'] as String?)?.substring(
                    0,
                    (review['comment'] as String?)!.length > 30
                        ? 30
                        : (review['comment'] as String?)!.length) ??
                '', // Short comment
            'sentiment': review['sentiment'] ?? 'neutral',
          };
        })
        .take(10)
        .toList(); // Limit number of reviews in prompt

    final String prompt = """
You are a food recommendation assistant for the "Foodie Fleet" app.
Your goal is to suggest 3 to 5 relevant menu items to the user.

Consider the following user data:
1. User's Past Ordered Item Names: ${pastOrderNames.isEmpty ? "None specified." : pastOrderNames.join(", ")}.
2. User's Past Menu Item Reviews: 
   ${jsonEncode(summarizedUserReviews.isEmpty ? "No past reviews." : summarizedUserReviews)}
   (Pay attention to highly rated items, positive sentiment, and items the user commented on favorably. Avoid recommending items similar to ones they rated poorly or had negative sentiment for, unless the available options are very limited.)

Here is a list of currently available menu items from various food trucks (format: [{'menu_id': id, 'name': name, 'truck_name': truckName, 'category': category, 'isVegan': bool, 'isSpicy': bool}, ...]): 
${jsonEncode(summarizedAvailableItems.take(40).toList())} 
// Limiting to 40 available items in prompt for token limits, adjust as needed.

**Recommendation Task:**
Based on the user's past orders AND their past reviews (especially ratings and sentiment), recommend 3 to 5 diverse and appealing 'menu_id's from the "Available menu items".
*   Prioritize items similar to what they've liked (ordered or reviewed positively).
*   Consider items that complement previous positive experiences.
*   If past data is sparse, suggest popular or highly-rated general options from the available list.
*   Try to offer some variety in terms of category or truck if possible.

Return ONLY a valid JSON array of strings, where each string is the 'menu_id' of a recommended item.
Example: ["menu_id_1", "menu_id_2", "menu_id_3"]
If no good recommendations can be made, return an empty JSON array: [].
""";
    try {
      final response = await http
          .post(
            url, headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'contents': [
                {
                  'parts': [
                    {'text': prompt}
                  ]
                }
              ],
              "generationConfig": {
                "temperature": 0.6,
                "response_mime_type": "application/json"
              }
            }), // Request JSON output
          )
          .timeout(const Duration(seconds: 45));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['candidates']?[0]?['content']?['parts']?[0]
            ?['text'] as String?;
        print("[SLIDER_DEBUG] AI Recommendation RAW JSON String: $content");
        return (content != null && content.trim().startsWith('['))
            ? content.trim()
            : '[]';
      }
      print(
          "[SLIDER_DEBUG] Gemini API Error (Recommendations): ${response.statusCode} - ${response.body}");
      return '[]';
    } catch (e) {
      print("[SLIDER_DEBUG] Error calling Gemini for recommendations: $e");
      return '[]';
    }
  }

  @override
  Widget build(BuildContext context) {
    print(
        "[SLIDER_DEBUG] build CALLED. isLoading: $_isLoading, error: $_errorMessage, items: ${_recommendedItems.length}");
    if (_isLoading) {
      return const SizedBox(
          height: 290,
          child: Center(
              child: CircularProgressIndicator(color: ffPrimaryColorSlider)));
    }
    if (_errorMessage.isNotEmpty) {
      return SizedBox(
          height: 290,
          child: Center(
              child: Padding(
            padding: const EdgeInsets.all(ffSizeMdSlider),
            child: Text(_errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.redAccent)),
          )));
    }
    if (_recommendedItems.isEmpty) {
      print(
          "[SLIDER_DEBUG] No recommended items to display, returning SizedBox.shrink()");
      return const SizedBox.shrink(); // Don't show slider if no items
    }

    print(
        "[SLIDER_DEBUG] Building ListView with ${_recommendedItems.length} items.");
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
              left: ffSizeMdSlider, top: ffSizeMdSlider, bottom: 10.0),
          child: Text("Recommended For You",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold, color: Colors.black87)),
        ),
        SizedBox(
          height: 295, // Height of the slider
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(
                left: ffSizeMdSlider,
                right: ffSizeMdSlider / 2,
                bottom: ffSizeSmCard / 2 +
                    ffSizeMdSlider / 2), // Added bottom padding for shadow
            itemCount: _recommendedItems.length,
            itemBuilder: (context, index) {
              final item = _recommendedItems[index];
              return RecommendationCard(
                menuItem: item,
                truckName:
                    item['truck_name_for_recommendation'] as String? ?? 'N/A',
              );
            },
          ),
        ),
      ],
    );
  }
}
