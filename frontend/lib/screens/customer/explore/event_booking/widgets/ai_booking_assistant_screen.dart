import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:myapp/core/services/truckOwner_service.dart'; // Adjust path
import 'package:myapp/core/services/menu_service.dart'; // Import MenuService
import 'package:myapp/screens/customer/explore/event_booking/widgets/final_booking_form.dart'; // Adjust path

// --- Styles ---
const Color ffPrimaryColor = Colors.orange;
const Color ffSurfaceColor = Colors.white;
const Color ffBackgroundColor = Color(0xFFF4F4F4);
const Color ffOnPrimaryColor = Colors.white;
const Color ffOnSurfaceColor = Color(0xFF2D2D2D);
const Color ffSecondaryTextColor = Color(0xFF666666);
const double ffPaddingMd = 16.0;
const double ffPaddingSm = 8.0;
const double ffPaddingLg = 24.0;
const double ffPaddingXs = 4.0;
const double ffBorderRadius = 12.0;

const List<String> supportedBookingCities = [
  "tulkarm", "ramallah", "salfit", "nablus", "jenin", "qalqilya"
];

class AIBookingAssistantScreen extends StatefulWidget {
  final String? initialCity;
  const AIBookingAssistantScreen({super.key, this.initialCity});

  @override
  State<AIBookingAssistantScreen> createState() => _AIBookingAssistantScreenState();
}

class _AIBookingAssistantScreenState extends State<AIBookingAssistantScreen> {
  final TextEditingController _queryController = TextEditingController();
  String _aiResponseText = "";
  bool _isLoading = false;
  List<Map<String, dynamic>> _bookingOptions = [];
  List<Map<String, dynamic>> _fetchedTrucks = [];
  List<Map<String, dynamic>> _relevantMenusWithTruckInfo = []; // To store menus of fetched trucks
  Map<String, dynamic> _extractedBookingParams = {};

  static const String _geminiApiKey = 'YOUR_GEMINI_API_KEY_HERE'; // <<<--- REPLACE THIS
  static final Uri _geminiUrl = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=$_geminiApiKey');

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  String _normalizeCity(String? cityNameFromAI) {
    if (cityNameFromAI == null || cityNameFromAI.isEmpty) {
      return widget.initialCity ?? "Qalqilya";
    }
    String normalized = cityNameFromAI.toLowerCase().trim();
    for (String supportedCity in supportedBookingCities) {
      if (normalized.contains(supportedCity)) {
        return supportedCity.substring(0, 1).toUpperCase() + supportedCity.substring(1);
      }
    }
    print("[AI_BOOKING_DEBUG] City '$cityNameFromAI' not in supported list, using as is.");
    return cityNameFromAI.isNotEmpty ? cityNameFromAI.substring(0, 1).toUpperCase() + cityNameFromAI.substring(1) : widget.initialCity ?? "Qalqilya";
  }

  Future<void> _getAIAssistance() async {
    if (_queryController.text.trim().isEmpty || !mounted) return;
    setState(() { _isLoading = true; _aiResponseText = ""; _bookingOptions = []; _extractedBookingParams = {}; _relevantMenusWithTruckInfo = []; });
    final userQuery = _queryController.text.trim();
    print("----------------------------------------------------");
    print("[AI_ASSIST_INPUT] User Query: $userQuery");

    try {
      _extractedBookingParams = await _extractBookingParametersFromAI(userQuery);
      print("[AI_ASSIST_PARAMS] Extracted by AI: $_extractedBookingParams");

      if (!mounted) return;
      if (_extractedBookingParams.isEmpty || _extractedBookingParams['error'] != null) {
        setState(() { _aiResponseText = _extractedBookingParams['error'] ?? "I couldn't understand. Try details like date, guests, city."; _isLoading = false; });
        return;
      }

      String cityExtractedByAI = _extractedBookingParams['city'] as String? ?? '';
      final String cityToSearch = _normalizeCity(cityExtractedByAI.isNotEmpty ? cityExtractedByAI : widget.initialCity);
      _extractedBookingParams['city'] = cityToSearch;

      print("[AI_ASSIST_CITY_SEARCH] Normalized City for Truck Search: $cityToSearch");

      final List<dynamic> rawTrucks = await TruckOwnerService.getPublicTrucks(city: cityToSearch);
      _fetchedTrucks = rawTrucks.map((truck) => truck as Map<String, dynamic>).toList();
      print("[AI_ASSIST_TRUCKS_FETCHED] Count of Trucks Fetched in '$cityToSearch': ${_fetchedTrucks.length}");

      if (!mounted) return;
      if (_fetchedTrucks.isEmpty) {
        setState(() { _aiResponseText = "Sorry, no trucks found in $cityToSearch for your request. Try another city or adjust criteria."; _isLoading = false; });
        return;
      }

      // --- Fetch ALL menus and then filter for relevant trucks ---
      final http.Response allMenusResponse = await MenuService.getAllMenusWithTrucks();
      if (allMenusResponse.statusCode == 200) {
        final List<dynamic> allMenusData = jsonDecode(allMenusResponse.body) as List<dynamic>? ?? [];
        final Set<String> fetchedTruckIds = _fetchedTrucks.map((t) => t['_id'] as String).toSet();

        _relevantMenusWithTruckInfo = allMenusData
            .where((menuGroup) => fetchedTruckIds.contains(menuGroup['truckId'] as String?))
            .map((menuGroup) {
          // Flatten the menu items and add truck info to each item
          List<Map<String,dynamic>> itemsWithTruck = [];
          if (menuGroup['menu'] is List) {
            for (var item in (menuGroup['menu'] as List)) {
              if (item is Map<String,dynamic>) {
                Map<String,dynamic> newItem = Map.from(item);
                newItem['truck_id_for_ai'] = menuGroup['truckId']; // Use original truckId from menuGroup
                newItem['truck_name_for_ai'] = menuGroup['truckName'];
                itemsWithTruck.add(newItem);
              }
            }
          }
          return itemsWithTruck; // This is a list of items for one truck
        })
            .expand((list) => list) // Flatten the list of lists into a single list of menu items
            .toList();
        print("[AI_ASSIST_MENUS] Relevant Menu Items Count: ${_relevantMenusWithTruckInfo.length}");
      } else {
        print("[AI_ASSIST_MENUS] Failed to fetch all menus: ${allMenusResponse.statusCode}");
        // Continue without menu context, AI will rely more on truck cuisine_type
      }
      // --- End of Menu Fetching and Filtering ---

      // AI generates options based on FULL _fetchedTrucks data and _relevantMenusWithTruckInfo
      final List<Map<String, dynamic>> suggestedOptionsFromAI = await _generateBookingOptionsFromAI(
          _extractedBookingParams,
          _fetchedTrucks,
          _relevantMenusWithTruckInfo // Pass relevant menus
      );
      print("[AI_ASSIST_SUGGESTIONS] AI Suggested Options (Raw from AI): $suggestedOptionsFromAI");

      if (!mounted) return;
      String responseMessageToShow = "";
      List<Map<String, dynamic>> optionsToDisplay = [];

      if (suggestedOptionsFromAI.isNotEmpty) {
        if (suggestedOptionsFromAI.first['truck_id'] == null && suggestedOptionsFromAI.first['reason'] != null) {
          responseMessageToShow = suggestedOptionsFromAI.first['reason'] ?? "The AI indicated no specific options could be found.";
        } else {
          optionsToDisplay = suggestedOptionsFromAI;
          responseMessageToShow = "Great! I found these options for you:";
        }
      } else {
        responseMessageToShow = "I looked, but couldn't find suitable booking options. You could try being more flexible.";
      }

      setState(() {
        _bookingOptions = optionsToDisplay;
        _aiResponseText = responseMessageToShow;
        _isLoading = false;
      });

    } catch (e, s) {
      if (!mounted) return;
      print("[AI_BOOKING_DEBUG] Error in _getAIAssistance: $e\n$s");
      setState(() { _aiResponseText = "An error occurred. Please try again."; _isLoading = false; });
    }
  }

  Future<Map<String, dynamic>> _extractBookingParametersFromAI(String userQuery) async {
    final String knownCitiesString = supportedBookingCities.join(", ");
    final String prompt = """
    Analyze the user's event booking request: "$userQuery"
    Extract the following parameters into a VALID JSON object:
    - "event_type": (string) e.g., "birthday party", "corporate event". If not clear, use "general event".
    - "preferred_date": (string) Parse specific dates (e.g., "July 20th, 2024", "20/7/2024") to YYYY-MM-DD. For relative dates ("next Saturday", "end of July"), keep the description. If no date, null.
    - "preferred_time": (string) e.g., "evening", "afternoon", "around 7 PM". If no time, null.
    - "guest_count": (integer) Total number of guests as an integer (e.g., "30 kids and 10 adults" -> 40). If not mentioned, null.
    - "city": (string) City name. Try to match it to one of these known cities: [$knownCitiesString]. If a close match like 'qalqilyyah' for 'qalqilya' is found, use the known city name 'Qalqilya'. If no city mentioned or cannot be matched, null.
    - "cuisine_preferences": (list of strings) e.g., ["Pizza", "Burgers"]. If "vegan food" is mentioned, include "Vegan" in this list. If "spicy food" is mentioned, include "Spicy". If "low calorie" or "healthy" is mentioned, include "Low Calorie". If none, empty list [].
    - "special_requests": (string) Capture ONLY specific dietary needs NOT covered by cuisine_preferences (e.g., "nut-free", "gluten-free pizza if possible") or specific non-food requests (e.g., "need space for music"). Do NOT include "food truck", "book a truck", cuisine types already in cuisine_preferences, or city names here. If none, null or empty string.

    User Request: "$userQuery"

    Example - Full Request: "I want to book a food truck for my son's birthday party on July 20th, 2024, in Jenin. We're expecting about 30 kids and 10 adults. He loves pizza and burgers. Need some vegan snacks too, and maybe low calorie options for adults."
    Output: { "event_type": "birthday party", "preferred_date": "2024-07-20", "preferred_time": "evening", "guest_count": 40, "city": "Jenin", "cuisine_preferences": ["Pizza", "Burgers", "Vegan", "Low Calorie"], "special_requests": "vegan snacks" }
    
    Return ONLY the JSON object. If crucial info like city is missing, return { "error": "Please specify the city for your event." }
    JSON Output:
    """;
    try {
      final response = await http.post(_geminiUrl, headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'contents': [{'parts': [{'text': prompt}]}], "generationConfig": {"temperature": 0.1, "response_mime_type": "application/json"}}),
      ).timeout(const Duration(seconds: 25));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['candidates']?[0]?['content']?['parts']?[0]?['text'] as String?;
        if (content != null) {
          print("[AI_BOOKING_DEBUG] Raw Params JSON from AI: $content");
          try { return jsonDecode(content) as Map<String, dynamic>; }
          catch (e) { print("[AI_BOOKING_DEBUG] Error decoding params JSON: $e"); return {'error': "AI response format error."}; }
        }
      }
      print("[AI_BOOKING_DEBUG] Params extraction failed: ${response.statusCode} - ${response.body}");
      return {'error': "AI parameter extraction failed."};
    } catch (e) { print("[AI_BOOKING_DEBUG] Params extraction communication error: $e");return {'error': "AI communication error."}; }
  }

  Future<List<Map<String, dynamic>>> _generateBookingOptionsFromAI(
      Map<String, dynamic> bookingParams,
      List<Map<String, dynamic>> allFetchedTrucks,
      List<Map<String, dynamic>> relevantMenus // NEW PARAMETER
      ) async {
    final summarizedTrucks = allFetchedTrucks.map((truck) => {
      'truck_id': truck['_id'], 'truck_name': truck['truck_name'], 'cuisine_type': truck['cuisine_type'],
      'description': (truck['description'] as String?)?.substring(0, (truck['description']as String?)!.length > 60 ? 60 : (truck['description']as String?)!.length) ?? "",
      'operating_hours': truck['operating_hours'],
      'unavailable_dates': (truck['unavailable_dates'] as List<dynamic>? ?? []).map((d) => d.toString().substring(0,10)).toList(),
      // Assuming these booleans might be directly on the truck object from your service
      'isVeganFriendlyTruck': truck['isVegan'] as bool? ?? false,
      'offersSpicyTruck': truck['isSpicy'] as bool? ?? false,
    }).toList();

    // Summarize relevant menu items to give AI context about specific dishes
    final summarizedRelevantMenus = relevantMenus.map((item) => {
      'menu_item_id': item['_id'],
      'menu_item_name': item['name'],
      'truck_id': item['truck_id_for_ai'], // ID of the truck this item belongs to
      'truck_name': item['truck_name_for_ai'],
      'isVegan': item['isVegan'] ?? false,
      'isSpicy': item['isSpicy'] ?? false,
      'calories': item['calories'],
      // 'category': item['category'], // Optional
    }).toList();

    final String prompt = """
    You are an expert event booking assistant for "Foodie Fleet".
    User preferences: ${jsonEncode(bookingParams)}
    Available trucks in the city (max 15 listed): ${jsonEncode(summarizedTrucks.take(15).toList())}
    Available menu items from these trucks (max 30 items listed for brevity, format: [{'menu_item_name', 'truck_id', 'isVegan', 'isSpicy', 'calories'}, ...]):
    ${jsonEncode(summarizedRelevantMenus.take(30).toList())} 
    Today: ${DateFormat('yyyy-MM-dd').format(DateTime.now())}.

    Task: Suggest **2 to 3 diverse and suitable booking options**. If only one good match, suggest one. If several, provide multiple.
    Each option (JSON object): "truck_id", "truck_name", "suggested_date" (YYYY-MM-DD, NOT unavailable), "suggested_start_time" (HH:MM AM/PM, in ops hours), "suggested_end_time" (2-3 hrs after start, in ops hours), "reason" (compelling, brief, mention if it matches key preferences like vegan/spicy/low-calorie by checking available menu items or truck flags).

    Strict Rules:
    1. Date must NOT be in truck's 'unavailable_dates'.
    2. Times MUST be within truck's 'operating_hours'.
    3. Cuisine Preferences:
        a. If "Vegan" is preferred, prioritize trucks with 'isVeganFriendlyTruck': true OR trucks that have 'isVegan': true menu items.
        b. If "Spicy" is preferred, prioritize trucks with 'offersSpicyTruck': true OR trucks that have 'isSpicy': true menu items.
        c. If "Low Calorie" is preferred, look for menu items with lower 'calories' (e.g., under 500) and suggest trucks offering them.
        d. For other cuisines (e.g., "Pizza"), prioritize trucks with matching 'cuisine_type'.
    4. Calculate relative dates. Interpret "evening" (6-9 PM), "afternoon" (1-4 PM).
    
    If no valid options, return JSON array with ONE object:
    [{ "truck_id":null, "reason":"No trucks in ${bookingParams['city']} match your preferences (e.g., ${(bookingParams['cuisine_preferences'] as List<dynamic>?)?.join(", ") ?? 'cuisine/dietary needs'}) for date ${bookingParams['preferred_date'] ?? 'requested'}. You might try adjusting criteria."}]
    
    Otherwise, return JSON array of booking option objects.
    JSON Output:
    """;
    try {
      final response = await http.post(_geminiUrl, headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'contents': [{'parts': [{'text': prompt}]}], "generationConfig": {"temperature": 0.55, "response_mime_type": "application/json"}}), // Slightly increased temp
      ).timeout(const Duration(seconds: 45)); // Increased timeout for more complex prompt
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['candidates']?[0]?['content']?['parts']?[0]?['text'] as String?;
        if (content != null) {
          print("[AI_BOOKING_DEBUG] Raw Options JSON from AI: $content");
          try {
            final options = jsonDecode(content) as List<dynamic>? ?? [];
            return options.map((opt) => opt as Map<String, dynamic>).toList();
          } catch (e) { print("[AI_BOOKING_DEBUG] Error decoding options JSON: $e \nContent: $content"); return []; }
        }
      }
      print("[AI_BOOKING_DEBUG] Options generation failed: ${response.statusCode} - ${response.body}");
      return [{"reason": "AI service failed to generate options (Status: ${response.statusCode})."}];
    } catch (e) { print("[AI_BOOKING_DEBUG] Options generation communication error: $e"); return [{"reason": "Could not reach AI service to generate options."}]; }
  }

  void _navigateToFinalBookingForm(Map<String, dynamic> truckData, Map<String, dynamic> selectedOption) {
    // ... (This method remains the same as your last correct version)
    DateTime parsedStartDate = DateTime.now(); DateTime parsedEndDate = DateTime.now();
    TimeOfDay? initialStartTime; TimeOfDay? initialEndTime;
    try {
      if (selectedOption['suggested_date'] != null) { parsedStartDate = DateFormat('yyyy-MM-dd').parseStrict(selectedOption['suggested_date']); parsedEndDate = parsedStartDate; }
      if (selectedOption['suggested_start_time'] != null) { initialStartTime = TimeOfDay.fromDateTime(DateFormat('hh:mm a').parse(selectedOption['suggested_start_time'])); }
      if (selectedOption['suggested_end_time'] != null) { initialEndTime = TimeOfDay.fromDateTime(DateFormat('hh:mm a').parse(selectedOption['suggested_end_time'])); }
    } catch(e) { print("Error parsing AI date/time: $e"); }
    int? initialGuestCountValue;
    final dynamic rawGuestCount = _extractedBookingParams['guest_count'];
    if (rawGuestCount != null) {
      if (rawGuestCount is String) initialGuestCountValue = int.tryParse(rawGuestCount);
      else if (rawGuestCount is int) initialGuestCountValue = rawGuestCount;
      else if (rawGuestCount is double) initialGuestCountValue = rawGuestCount.toInt();
    }
    String? specialRequestsFromAI = _extractedBookingParams['special_requests'] as String?;
    if (specialRequestsFromAI != null && specialRequestsFromAI.trim().isNotEmpty) {
      final List<String> commonPhrasesToIgnore = ["food truck", "book a truck", "truck for", "event", "party", "birthday"];
      bool containsCommonPhrase = commonPhrasesToIgnore.any((phrase) => specialRequestsFromAI!.toLowerCase().contains(phrase));
      List<String> cuisinePrefsLower = ((_extractedBookingParams['cuisine_preferences'] as List<dynamic>?)?.map((e) => e.toString().toLowerCase()).toList() ?? []);
      bool containsCuisine = cuisinePrefsLower.any((c) => specialRequestsFromAI!.toLowerCase().contains(c));
      if (containsCommonPhrase || containsCuisine) {
        final List<String> dietaryKeywords = ["vegan", "nut-free", "gluten-free", "vegetarian", "halal", "kosher", "allergy", "allergic", "no pork", "no beef", "low calorie"];
        bool containsDietaryKeyword = dietaryKeywords.any((keyword) => specialRequestsFromAI!.toLowerCase().contains(keyword));
        if (!containsDietaryKeyword) specialRequestsFromAI = null;
      }
    } else { specialRequestsFromAI = null; }
    Navigator.push(context, MaterialPageRoute(builder: (_) => FinalBookingForm(truck: truckData, selectedDateRange: DateTimeRange(start: parsedStartDate, end: parsedEndDate), initialStartTime: initialStartTime, initialEndTime: initialEndTime, initialGuestCount: initialGuestCountValue, initialLocation: _extractedBookingParams['city'] as String?, initialSpecialRequests: specialRequestsFromAI,),),);
  }

  @override
  Widget build(BuildContext context) {
    // --- UI Structure (Same as your previous correct version) ---
    return Scaffold(
      backgroundColor: ffBackgroundColor,
      appBar: AppBar(title: const Text("AI Event Booking Assistant"), backgroundColor: ffPrimaryColor, foregroundColor: ffOnPrimaryColor, elevation: 1),
      body: Padding(
        padding: const EdgeInsets.all(ffPaddingMd),
        child: Column(
          children: [
            Text("Tell me about your event!", style: Theme.of(context).textTheme.titleLarge?.copyWith(color: ffOnSurfaceColor, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
            const SizedBox(height: ffPaddingSm),
            Text("e.g., 'Book a pizza truck for 30 people in Jenin next Friday.'", style: Theme.of(context).textTheme.bodySmall?.copyWith(color: ffSecondaryTextColor), textAlign: TextAlign.center),
            const SizedBox(height: ffPaddingMd),
            TextField(
              controller: _queryController,
              decoration: InputDecoration(
                hintText: "Describe your event needs here...",
                hintStyle: TextStyle(color: ffSecondaryTextColor.withOpacity(0.7)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(ffBorderRadius), borderSide: BorderSide(color: Colors.grey.shade300)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(ffBorderRadius), borderSide: BorderSide(color: Colors.grey.shade300)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(ffBorderRadius), borderSide: const BorderSide(color: ffPrimaryColor, width: 1.5)),
                filled: true, fillColor: ffSurfaceColor,
                suffixIcon: IconButton(icon: Icon(Icons.send_rounded, color: _isLoading ? Colors.grey : ffPrimaryColor), onPressed: _isLoading ? null : _getAIAssistance,),
              ),
              textInputAction: TextInputAction.send, onSubmitted: _isLoading ? null : (_) => _getAIAssistance(),
              maxLines: 3, minLines: 1,
            ),
            const SizedBox(height: ffPaddingLg),
            if (_isLoading) const Expanded(child: Center(child: CircularProgressIndicator(color: ffPrimaryColor)))
            else if (_bookingOptions.isNotEmpty)
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(_aiResponseText, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: ffPrimaryColor, fontWeight: FontWeight.bold)),
                  const SizedBox(height: ffPaddingMd),
                  Expanded(child: ListView.builder(
                    itemCount: _bookingOptions.length,
                    itemBuilder: (context, index) {
                      final option = _bookingOptions[index];
                      if (option['truck_id'] == null && option['reason'] != null) {
                        return Card( elevation: 2, margin: const EdgeInsets.only(bottom: ffPaddingMd - 4), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ffBorderRadius - 2)),
                            child: ListTile( contentPadding: const EdgeInsets.symmetric(horizontal: ffPaddingMd -4, vertical: ffPaddingSm -2), leading: CircleAvatar(backgroundColor: Colors.orange.withOpacity(0.15), child: Icon(Icons.info_outline, color: Colors.orange, size: 26,)), title: Text("Information", style: TextStyle(fontWeight: FontWeight.w600, color: ffOnSurfaceColor.withOpacity(0.9), fontSize: 16)), subtitle: Text(option['reason'], style: const TextStyle(fontSize: 13, color: ffSecondaryTextColor)),)
                        );
                      }
                      final truckData = _fetchedTrucks.firstWhere((t) => t['_id'] == option['truck_id'], orElse: () => {'truck_name': option['truck_name'] ?? "Unknown Truck", '_id': option['truck_id']});
                      return Card(elevation: 2, margin: const EdgeInsets.only(bottom: ffPaddingMd - 4), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ffBorderRadius - 2)),
                        child: ListTile( contentPadding: const EdgeInsets.symmetric(horizontal: ffPaddingMd -4, vertical: ffPaddingSm -2), leading: CircleAvatar(backgroundColor: ffPrimaryColor.withOpacity(0.15), child: const Icon(Icons.calendar_month_outlined, color: ffPrimaryColor, size: 26,)), title: Text(option['truck_name'] ?? 'Truck Option', style: TextStyle(fontWeight: FontWeight.w600, color: ffOnSurfaceColor.withOpacity(0.9), fontSize: 16)),
                          subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [ const SizedBox(height: ffPaddingXs/2), Text("📅 Date: ${option['suggested_date'] ?? 'N/A'}", style: const TextStyle(fontSize: 13, color: ffSecondaryTextColor)), Text("🕒 Time: ${option['suggested_start_time'] ?? 'N/A'} - ${option['suggested_end_time'] ?? 'N/A'}", style: const TextStyle(fontSize: 13, color: ffSecondaryTextColor)), if (option['reason'] != null && (option['reason'] as String).isNotEmpty) ...[const SizedBox(height: ffPaddingXs), Text("✨ Why: ${option['reason']}", style: TextStyle(fontSize: 12.5, fontStyle: FontStyle.italic, color: ffSecondaryTextColor.withOpacity(0.95))),]]),
                          trailing: Icon(Icons.arrow_forward_ios_rounded, size: 18, color: ffSecondaryTextColor.withOpacity(0.8)), onTap: () { if(truckData.isNotEmpty && truckData['_id'] != null) _navigateToFinalBookingForm(truckData, option); else ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Details for truck option incomplete."))); },
                        ),);},),),
                ],),)
            else if (_aiResponseText.isNotEmpty)
                Expanded(child: Center(child: Padding( padding: const EdgeInsets.all(8.0), child: Text(_aiResponseText, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, color: ffSecondaryTextColor)),)))
          ],
        ),
      ),
    );
  }
}