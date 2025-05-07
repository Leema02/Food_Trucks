import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:myapp/screens/truckOwner/manageMenu/viewMenu.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myapp/core/services/truckOwner_service.dart';
import 'package:myapp/screens/auth/widgets/auth_background.dart';
import 'package:myapp/screens/truckOwner/manageTrucks/editTruck.dart';
import 'package:myapp/core/utils/url_helper.dart';

class ViewTrucksScreen extends StatefulWidget {
  const ViewTrucksScreen({super.key});

  @override
  State<ViewTrucksScreen> createState() => _ViewTrucksScreenState();
}

class _ViewTrucksScreenState extends State<ViewTrucksScreen> {
  List<dynamic> trucks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTrucks();
  }

  Future<void> fetchTrucks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await TruckOwnerService.getMyTrucks(token);
      if (response.statusCode == 200) {
        setState(() {
          trucks = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        print('Failed to fetch trucks: ${response.body}');
        setState(() => isLoading = false);
      }
    } catch (e) {
      print('Error: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> deleteTruck(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete this truck?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final response = await TruckOwnerService.deleteTruck(id, token);
      if (response.statusCode == 200) {
        _showMessage('✅ Truck deleted successfully.');
        fetchTrucks(); // Refresh list
      } else {
        _showMessage('❌ Failed to delete truck.');
      }
    }
  }

  void _showMessage(String message) {
    final snackBar = SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: const Color.fromARGB(255, 89, 56, 39),
      content: Text(message, textAlign: TextAlign.center),
      duration: const Duration(seconds: 2),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Trucks',
          style: TextStyle(
            fontSize: 22,
            color: Colors.black,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 255, 136, 0),
      ),
      body: AuthBackground(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : trucks.isEmpty
                ? const Center(child: Text('No trucks found.'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: trucks.length,
                    itemBuilder: (context, index) {
                      final truck = trucks[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            ListTile(
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(
                                    getFullImageUrl(truck['logo_image_url'])),
                                radius: 25,
                              ),
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    truck['truck_name'] ?? '',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  if (truck['description'] != null &&
                                      truck['description']
                                          .toString()
                                          .isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        truck['description'],
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      'Cuisine: ${truck['cuisine_type'] ?? ''}'),
                                  Text(
                                      'Address: ${truck['location']?['address_string'] ?? ''}'),
                                  Text(
                                    'Hours: ${truck['operating_hours']?['open'] ?? ''} - ${truck['operating_hours']?['close'] ?? ''}',
                                  ),
                                ],
                              ),
                              isThreeLine: true,
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.orange),
                                    onPressed: () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              EditTruckPage(truck: truck),
                                        ),
                                      );

                                      if (result == true) {
                                        fetchTrucks(); // Refresh after editing
                                      }
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline,
                                        color: Colors.redAccent),
                                    onPressed: () => deleteTruck(truck['_id']),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  bottom: 12, left: 12, right: 12),
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ManageMenuPage(
                                          truckId: truck['_id'],
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.restaurant_menu),
                                  label: const Text('Manage Menu'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.deepOrange,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
