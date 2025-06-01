import 'package:flutter/material.dart';
import 'package:myapp/core/services/truckOwner_service.dart';
import 'package:myapp/screens/customer/explore/event_booking/truck_booking_screen.dart';
// Import the AI Booking Assistant Screen - ADJUST THE PATH AS NEEDED
import 'package:myapp/screens/customer/explore/event_booking/widgets/ai_booking_assistant_screen.dart';


// --- Style constants for the AI Assistant button (Foodie Fleet Theme) ---
// You can move these to a central style file if you have one
const Color ffPrimaryColor = Colors.orange;
const Color ffOnPrimaryColor = Colors.white;
const Color ffSurfaceColor = Colors.white; // For potential card around the button
const double ffPaddingMd = 16.0;
const double ffPaddingSm = 8.0;
const double ffPaddingLg = 24.0;
const double ffBorderRadius = 12.0;
// --- End Style Constants ---


class EventBookingSelector extends StatefulWidget {
  const EventBookingSelector({super.key});

  @override
  State<EventBookingSelector> createState() => _EventBookingSelectorState();
}

class _EventBookingSelectorState extends State<EventBookingSelector> {
  List<dynamic> trucks = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchTrucks();
  }

  Future<void> fetchTrucks() async {
    // Ensure mounted check if async operation might complete after dispose
    if (!mounted) return;
    setState(() {
      isLoading = true;
      errorMessage = '';
    });
    try {
      final data = await TruckOwnerService.getPublicTrucks();
      if (!mounted) return;
      setState(() {
        trucks = data;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = "Failed to load trucks: ${e.toString()}";
        isLoading = false;
      });
    }
  }

  void _onPlanWithAI() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AIBookingAssistantScreen(),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    // Main content بناءً على حالة التحميل أو الخطأ
    Widget mainContent;

    if (isLoading) {
      mainContent = const Center(child: CircularProgressIndicator(color: ffPrimaryColor));
    } else if (errorMessage.isNotEmpty) {
      mainContent = Center(
          child: Padding(
            padding: const EdgeInsets.all(ffPaddingMd),
            child: Text(errorMessage, style: const TextStyle(color: Colors.redAccent, fontSize: 16), textAlign: TextAlign.center),
          )
      );
    } else if (trucks.isEmpty) {
      mainContent = const Center(
          child: Padding(
            padding: EdgeInsets.all(ffPaddingMd),
            child: Text("No trucks currently available for event booking. Please check back later!", style: TextStyle(fontSize: 16, color: Colors.grey), textAlign: TextAlign.center),
          )
      );
    }
    else {
      mainContent = Expanded( // Make ListView take remaining space
        child: ListView.builder(
          padding: const EdgeInsets.only(top: ffPaddingSm, bottom: ffPaddingLg), // Add some padding
          itemCount: trucks.length,
          itemBuilder: (context, index) {
            final truck = trucks[index];
            return Card( // Wrap ListTile in a Card for better UI
              margin: const EdgeInsets.symmetric(horizontal: ffPaddingMd, vertical: ffPaddingSm / 2),
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ffBorderRadius)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: ffPrimaryColor.withOpacity(0.1),
                  child: Icon(Icons.fire_truck, color: ffPrimaryColor), // More relevant icon
                ),
                title: Text(truck['truck_name'] ?? 'Unnamed Truck', style: const TextStyle(fontWeight: FontWeight.w600, color: ffOnSurfaceColor)),
                subtitle: Text("Cuisine: ${truck['cuisine_type'] ?? 'N/A'} - City: ${truck['city'] ?? 'Unknown'}", style: TextStyle(color: ffSecondaryTextColor)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: ffPrimaryColor),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TruckBookingScreen(truck: truck),
                    ),
                  );
                },
              ),
            );
          },
        ),
      );
    }

    return Scaffold( // Added Scaffold for AppBar and consistent structure
      backgroundColor: const Color(0xFFF9F9F9), // Light background
      body: Column( // Main Column for the page
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // --- AI Assistant Button ---
          Padding(
            padding: const EdgeInsets.fromLTRB(ffPaddingMd, ffPaddingMd, ffPaddingMd, ffPaddingMd),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.auto_awesome_outlined, color: ffOnPrimaryColor),
              label: const Text("Plan Event with AI Assistant", style: TextStyle(color: ffOnPrimaryColor, fontSize: 16)),
              onPressed: _onPlanWithAI,
              style: ElevatedButton.styleFrom(
                  backgroundColor: ffPrimaryColor,
                  padding: const EdgeInsets.symmetric(vertical: ffPaddingMd - 2, horizontal: ffPaddingLg), // 14, 24
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ffBorderRadius)),
                  textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
              ),
            ),
          ),
          // --- End AI Assistant Button ---

          Padding( // Optional: Add a title for the manual selection part
            padding: const EdgeInsets.symmetric(horizontal: ffPaddingMd, vertical: ffPaddingSm),
            child: Text(
              "Or Select a Truck Manually:",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: ffSecondaryTextColor),
            ),
          ),

          // The mainContent (Loader, Error, Empty, or ListView)
          mainContent,
        ],
      ),
    );
  }
}