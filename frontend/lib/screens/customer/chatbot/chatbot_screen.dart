// lib/screens/chatbot_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

// Import your UI components (adjust paths as necessary)
//import 'components/MessageLine.dart';
import 'components/chat_app_bar.dart';
import 'components/message_list.dart';
import 'components/message_input_bar.dart';

// Import your services (adjust paths as necessary)
import '../../../core/services/order_service.dart';
import '../../../core/services/truckOwner_service.dart';
import '../../../core/services/menu_service.dart';

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({super.key});

  @override
  ChatBotScreenState createState() => ChatBotScreenState();
}

class ChatBotScreenState extends State<ChatBotScreen> {
  final TextEditingController messageTextController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> messages = [];

  // TODO: Replace with your actual user token retrieval logic
  //final String _userToken = "YOUR_USER_TOKEN_IF_NEEDED";

  @override
  void initState() {
    super.initState();
    _addBotMessage(
        "👋 Hi! I'm your Foodie Fleet assistant. How can I help you today?");
  }

  void _addBotMessage(String text, {bool isLoading = false}) {
    if (mounted) {
      setState(() {
        messages.add({
          'sender': 'bot',
          'text': text,
          'timestamp': DateTime.now(),
          'isLoading': isLoading,
        });
      });
      // Ensure scroll happens after the frame is built, especially for initial messages
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    }
  }

  @override
  void dispose() {
    messageTextController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4), // Light grey background
      appBar: const ChatAppBar(),
      body: Column(
        children: [
          MessageList(
            messages: messages,
            scrollController: _scrollController,
          ),
          MessageInputBar(
            controller: messageTextController,
            onSendMessage: _handleUserMessage,
          ),
        ],
      ),
    );
  }

  void _handleUserMessage() async {
    final messageText = messageTextController.text.trim();
    if (messageText.isNotEmpty) {
      if (mounted) {
        setState(() {
          messages.add({
            'sender': 'user',
            'text': messageText,
            'timestamp': DateTime.now(),
          });
        });
      }
      messageTextController.clear();
      _scrollToBottom(); // Scroll after user message is added

      _addBotMessage("🤖 Thinking...", isLoading: true); // Add thinking message

      final botResponse = await _getAIResponseForQuery(messageText);

      if (mounted) {
        setState(() {
          // Remove the "Thinking..." message
          messages.removeWhere(
              (msg) => msg['isLoading'] == true && msg['sender'] == 'bot');
        });
        _addBotMessage(
            botResponse ?? "Sorry, I couldn't process that right now.");
        // _scrollToBottom(); // _addBotMessage already calls this
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients && messages.isNotEmpty) {
      // Add a small delay to ensure the new message is laid out before scrolling
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          // Check again in case disposed during delay
          _scrollController.animateTo(
            0.0, // Scroll to the "top" because the list is reversed
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  // --- Intent Classification (Simple Keyword-Based) ---
  // --- Data Fetching Helpers ---
  Future<String> _fetchOrdersData() async {
    try {
      final response = await OrderService.getMyOrders(); // Pass token
      if (response.statusCode == 200) {
        try {
          jsonDecode(response.body) as List;
          return response.body;
        } catch (_) {
          return "[]";
        }
      }
      return "[]";
    } catch (e) {
      print("Error fetching orders: $e");
      return "[]";
    }
  }

  Future<List<dynamic>> _fetchTrucksListData() async {
    try {
      return await TruckOwnerService.getPublicTrucks();
    } catch (e) {
      print("Error fetching trucks list: $e");
      return [];
    }
  }

  Future<String> _fetchAllMenusData() async {
    try {
      final response = await MenuService.getAllMenusWithTrucks();
      if (response.statusCode == 200) {
        try {
          jsonDecode(response.body) as List;
          return response.body;
        } catch (_) {
          return "[]";
        }
      }
      return "[]";
    } catch (e) {
      print("Error fetching all menus: $e");
      return "[]";
    }
  }

  // List<dynamic> _filterMenuItems(List<dynamic> allMenus,
  //     {bool? isVegan, bool? isSpicy}) {
  //   return allMenus
  //       .map((truckMenu) {
  //         final filteredItems = (truckMenu['menu'] as List).where((item) {
  //           bool matches = true;
  //           if (isVegan != null) matches &= item['isVegan'] == isVegan;
  //           if (isSpicy != null) matches &= item['isSpicy'] == isSpicy;
  //           return matches;
  //         }).toList();
  //         return {...truckMenu, 'menu': filteredItems};
  //       })
  //       .where((truckMenu) => (truckMenu['menu'] as List).isNotEmpty)
  //       .toList();
  // }

  List<dynamic> _filterTrucksByCuisine(
      List<dynamic> trucks, String cuisineType) {
    return trucks
        .where((truck) => truck['cuisine_type']
            .toString()
            .toLowerCase()
            .contains(cuisineType.toLowerCase()))
        .toList();
  }

  // List<dynamic> _filterTrucksByCity(List<dynamic> trucks, String city) {
  //   return trucks.where((truck) =>
  //       truck['city'].toString().toLowerCase().contains(city.toLowerCase())
  //   ).toList();
  // }

// For cuisine type filtering

  DateTime? _parseDateFromQuery(String query) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    query = query.toLowerCase();

    // Handle relative dates
    if (query.contains("tomorrow")) {
      return today.add(const Duration(days: 1));
    } else if (query.contains("today")) {
      return today;
    } else if (query.contains("next week")) {
      return today.add(const Duration(days: 7));
    } else if (query.contains("next month")) {
      return DateTime(today.year, today.month + 1, today.day);
    }

    // Handle day-month-year format (12-5-2025 = May 12th)
    final dayMonthYearRegEx = RegExp(r'\b(\d{1,2})[-/](\d{1,2})[-/](\d{4})\b');
    final dmyMatch = dayMonthYearRegEx.firstMatch(query);
    if (dmyMatch != null) {
      try {
        return DateTime(
          int.parse(dmyMatch.group(3)!), // Year
          int.parse(dmyMatch.group(2)!), // Month
          int.parse(dmyMatch.group(1)!), // Day
        );
      } catch (e) {
        print("Error parsing day-month-year format: $e");
      }
    }

    // Handle other date formats
    final datePatterns = [
      DateFormat("yyyy-MM-dd"),
      DateFormat("MM-dd-yyyy"),
      DateFormat("dd-MM-yyyy"),
      DateFormat("MMMM d, yyyy"),
      DateFormat("d MMMM yyyy"),
    ];

    for (final format in datePatterns) {
      try {
        return format.parseStrict(query);
      } catch (_) {}
    }

    // Fallback to ISO parsing
    final isoMatch = RegExp(r"\b\d{4}-\d{2}-\d{2}\b").firstMatch(query);
    if (isoMatch != null) {
      return DateTime.tryParse(isoMatch.group(0)!);
    }

    return null;
  }

  Future<String?> _getAIResponseForQuery(String userQuery) async {
    final String intent = await _classifyUserIntent(userQuery);

    // Handle greetings/thanks
    if (intent == "GREETING_OR_THANKS") {
      return _handleGreetings(userQuery);
    }

    // Fetch all data
    final ordersJsonString = await _fetchOrdersData();
    final allTrucksList = await _fetchTrucksListData();
    final allMenusList = jsonDecode(await _fetchAllMenusData());

    // Initialize filters
    dynamic filteredTrucks = allTrucksList;
    dynamic filteredMenus = allMenusList;
    String customFiltersNote = "";
    DateTime? queriedDate;
    int? queriedMonth;
    bool isVegan = false;
    bool isSpicy = false;
    String? targetCity;

    // ====== DATE/MONTH PARSING ======
    queriedDate = _parseDateFromQuery(userQuery);

    // Handle month-only queries
    if (queriedDate == null) {
      final monthMatch = RegExp(
              r'\b(jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)\w*\b',
              caseSensitive: false)
          .firstMatch(userQuery);
      if (monthMatch != null) {
        try {
          queriedDate = DateFormat('MMMM').parse(monthMatch.group(0)!);
          queriedMonth = queriedDate.month;
        } catch (e) {
          print("Error parsing month: $e");
        }
      }
    }

    // ====== CITY FILTER ======
    final cityMatch =
        RegExp(r'\b(tulkarm|ramallah|salfit|nablus|jenin|qalqilya)\b')
            .firstMatch(userQuery.toLowerCase());
    if (cityMatch != null) {
      targetCity = cityMatch.group(0)!;
      filteredTrucks = _filterTrucksByCity(filteredTrucks, targetCity);
      customFiltersNote += "In $targetCity. ";
    }

    // ====== DATE AVAILABILITY ======
    if (queriedDate != null) {
      filteredTrucks = _getAvailableTrucksForDate(filteredTrucks, queriedDate);
      customFiltersNote +=
          "Available on ${DateFormat('MMMM d, yyyy').format(queriedDate)}. ";
    } else if (queriedMonth != null) {
      filteredTrucks = _getAvailableTrucksForMonth(
          filteredTrucks, DateTime.now().year, queriedMonth);
      customFiltersNote +=
          "Available throughout ${DateFormat('MMMM').format(DateTime(2024, queriedMonth))}. ";
    }

    // ====== CUISINE FILTER ======
    final cuisineMatch = RegExp(
            r'\b(coffee|desserts|mexican|asian|vegan|fried chicken|falafel|ice cream)\b')
        .firstMatch(userQuery.toLowerCase());
    if (cuisineMatch != null) {
      filteredTrucks =
          _filterTrucksByCuisine(filteredTrucks, cuisineMatch.group(0)!);
      customFiltersNote += "${cuisineMatch.group(0)} cuisine. ";
    }

    // ====== MENU FILTERING ======
    if (intent == "MENU_INQUIRY") {
      // Get truck IDs from filtered trucks
      final truckIds =
          filteredTrucks.map<String>((t) => t['_id'].toString()).toList();

      // Filter menus to only include trucks from filteredTrucks
      filteredMenus = (allMenusList as List)
          .where((menu) => truckIds.contains(menu['truckId'].toString()))
          .toList();

      // Apply dietary filters
      isVegan = userQuery.toLowerCase().contains('vegan');
      isSpicy = userQuery.toLowerCase().contains('spicy');

      if (isVegan || isSpicy) {
        filteredMenus = filteredMenus
            .map((menu) {
              final filteredItems = (menu['menu'] as List).where((item) {
                bool match = true;
                if (isVegan) match = match && (item['isVegan'] == true);
                if (isSpicy) match = match && (item['isSpicy'] == true);
                return match;
              }).toList();
              return {...menu, 'menu': filteredItems};
            })
            .where((menu) => (menu['menu'] as List).isNotEmpty)
            .toList();
      }
    }

    // ====== BUILD AI PROMPT ======
    const apiKey = 'AIzaSyCsfzNXk_nP9V5my0gqNc5wV0-kPcPZ9YU';
    final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=$apiKey');

    final prompt = """
**You are Foodie Fleet Assistant** - Comprehensive Response System
- MUST list ALL matching items
- NEVER say "0 results" if data exists
- ALWAYS follow format: "[Item] - [Truck] (\$Price) [Tags]"

=== FILTER CONTEXT ===
${customFiltersNote.isNotEmpty ? "• $customFiltersNote" : "No filters"}

=== TRUCK DATA ===
${filteredTrucks.map((t) => "${t['truck_name']} (${t['_id']})").join('\n')}


**EXAMPLE RESPONSE FOR SALFIT VEGAN:**
"In Salfit, vegan options:
• Ergonomic Cotton Pants - Langworth Truck (\$16.75) Vegan, Spicy"

=== ORDERS ===
${ordersJsonString.isNotEmpty ? ordersJsonString : "No recent orders"}

=== FILTERED TRUCKS ===
- Count: ${filteredTrucks.length}
- Filters: ${customFiltersNote.isNotEmpty ? customFiltersNote : "None"}
- Truck List:
${_formatTruckList(filteredTrucks)}

=== FILTERED MENUS ===
- Total Items: ${_countMenuItems(filteredMenus)}
- Dietary Filters: ${isVegan ? 'Vegan' : ''}${isSpicy ? 'Spicy' : ''}
- Menu Structure:
${_formatMenuList(filteredMenus)}

**Response Rules:**
1. For city requests: "In [city], we have [X] trucks with [dietary] options:"
2. Menu items must be paired with their truck name
3. Always include: Item name, Truck name, Price, Vegan/Spicy status
4. Example: "• [Item Name] - [Truck Name] (\$X.XX) [Vegan] [Spicy]"

**Sample Response Structure:**
"In Salfit, we found 2 trucks with vegan options:
• Intelligent Aluminum Shirt - Gutmann Truck (\$12.85) Vegan
• Sleek Concrete Bike - Gutmann Truck (\$8.15) Vegan, Spicy" 

User Query: "$userQuery"
Assistant Response:""";

    // Send to AI
    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'contents': [
                {
                  'parts': [
                    {'text': prompt}
                  ]
                }
              ],
              "generationConfig": {
                "temperature": 0.3,
                "topP": 0.95,
                "maxOutputTokens": 1024
              }
            }),
          )
          .timeout(const Duration(seconds: 30));

      return _parseAIResponse(response) ??
          "I couldn't process that. Please try again.";
    } catch (e) {
      return "Sorry, I'm having trouble right now. Please try again later.";
    }
  }

// ====== HELPER FUNCTIONS ======
  List<dynamic> _filterTrucksByCity(List<dynamic> trucks, String city) {
    final lowerCity = city.trim().toLowerCase();
    return trucks
        .where((truck) =>
            truck['city'].toString().trim().toLowerCase() == lowerCity)
        .toList();
  }

  // List<dynamic> _filterMenuItems(List<dynamic> menus, {bool? isVegan, bool? isSpicy}) {
  //   return menus.map((menu) {
  //     final filteredItems = (menu['menu'] as List).where((item) {
  //       bool match = true;
  //       if (isVegan != null) match = match && (item['isVegan'] == isVegan);
  //       if (isSpicy != null) match = match && (item['isSpicy'] == isSpicy);
  //       return match;
  //     }).toList();
  //     return {...menu, 'menu': filteredItems};
  //   }).where((menu) => (menu['menu'] as List).isNotEmpty).toList();
  // }

  String _formatTruckList(List<dynamic> trucks) {
    return trucks
        .map((t) =>
            "- ${t['truck_name']} (${t['cuisine_type']}) | ID: ${t['_id']} | City: ${t['city']}")
        .join('\n');
  }

  String _formatMenuList(List<dynamic> menus) {
    return menus
        .map((m) =>
            "Truck: ${m['truckName']} (${m['truckId']})\n${(m['menu'] as List).map((item) => "  • ${item['name']} - \$${item['price']} | " + "Vegan: ${item['isVegan']} | Spicy: ${item['isSpicy']}").join('\n')}")
        .join('\n\n');
  }

  int _countMenuItems(List<dynamic> menus) {
    return menus.fold(0, (sum, menu) => sum + (menu['menu'] as List).length);
  }

  List<dynamic> _getAvailableTrucksForDate(
      List<dynamic> trucks, DateTime date) {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    return trucks.where((truck) {
      final unavailable = (truck['unavailable_dates'] as List<dynamic>?)
              ?.whereType<String>()
              .map((d) => d.substring(0, 10))
              .toList() ??
          [];
      return !unavailable.contains(dateStr);
    }).toList();
  }

  List<dynamic> _getAvailableTrucksForMonth(
      List<dynamic> trucks, int year, int month) {
    return trucks.where((truck) {
      final unavailableMonths = (truck['unavailable_dates'] as List<dynamic>?)
              ?.map((d) => DateTime.parse(d as String))
              .where((dt) => dt.year == year && dt.month == month)
              .toList() ??
          [];
      return unavailableMonths.isEmpty;
    }).toList();
  }

  // ========== ENHANCED INTENT CLASSIFICATION ==========
  Future<String> _classifyUserIntent(String userQuery) async {
    final query = userQuery.toLowerCase();

    // Orders Intent
    if (RegExp(r'(order|purchase|status)\b.*(status|track|where|when)')
            .hasMatch(query) ||
        RegExp(r'\b(my orders?)\b').hasMatch(query)) {
      return "ORDERS_INQUIRY";
    }

    // Trucks Intent
    if (RegExp(r'\b(truck|available|open|close|schedule|hours|location|address|cuisine|city)\b')
            .hasMatch(query) ||
        RegExp(r'(where is|when does|operating hours)').hasMatch(query)) {
      return "TRUCKS_INQUIRY";
    }

    // Menu Intent
    if (RegExp(r'\b(menu|food|dish|meal|item|vegan|spicy|vegetarian|calorie|price|calories)\b')
            .hasMatch(query) ||
        RegExp(r'(what to eat|options for|find.*food)').hasMatch(query)) {
      return "MENU_INQUIRY";
    }

    // Greetings/Thanks
    if (RegExp(r'^(hi|hello|hey|thanks|thank you|ok|okay)\b').hasMatch(query)) {
      return "GREETING_OR_THANKS";
    }

    return "GENERAL_CONVERSATION";
  }

  // --- Main AI Query Logic ---

  String? _parseAIResponse(http.Response response) {
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['candidates']?[0]?['content']?['parts']?[0]?['text']
          as String?;
    }
    return null;
  }

  String _handleGreetings(String query) {
    query = query.toLowerCase();
    if (query.startsWith("hi") || query.startsWith("hello"))
      return "Hello! Ready to explore food trucks?";
    if (query.contains("thank"))
      return "You're welcome! Let me know if you need anything else.";
    return "How can I assist with your food truck experience today?";
  }
}

// === MENU DATA ===
// ${filteredMenus.map((m) =>
// "Truck: ${m['truckName']}\n" +
// (m['menu'].map((i) =>
// "• ${i['name']} (Vegan: ${i['isVegan']}, Spicy: ${i['isSpicy']})"
// ).join('\n')
// ).join('\n\n'))}
