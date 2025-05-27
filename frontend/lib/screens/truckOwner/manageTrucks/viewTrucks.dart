import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myapp/core/services/truckOwner_service.dart';
import 'package:myapp/core/utils/url_helper.dart';
import 'package:myapp/core/constants/supported_cities.dart';
import 'package:myapp/screens/auth/widgets/auth_background.dart';
import 'package:myapp/screens/truckOwner/manageMenu/viewMenu.dart';
import 'package:myapp/screens/truckOwner/manageTrucks/editTruck.dart';
import 'package:easy_localization/easy_localization.dart';

class ViewTrucksScreen extends StatefulWidget {
  const ViewTrucksScreen({super.key});

  @override
  State<ViewTrucksScreen> createState() => _ViewTrucksScreenState();
}

class _ViewTrucksScreenState extends State<ViewTrucksScreen> {
  List<dynamic> allTrucks = [];
  List<dynamic> filteredTrucks = [];
  bool isLoading = true;
  String? selectedCityFilter;

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
        final trucks = jsonDecode(response.body);
        setState(() {
          allTrucks = trucks;
          applyFilter();
          isLoading = false;
        });
      } else {
        _showMessage('failed_to_fetch_trucks'.tr());
        setState(() => isLoading = false);
      }
    } catch (e) {
      _showMessage('${'error_occurred'.tr()}: $e');
      setState(() => isLoading = false);
    }
  }

  void applyFilter() {
    if (selectedCityFilter == null) {
      filteredTrucks = allTrucks;
    } else {
      filteredTrucks =
          allTrucks.where((t) => t['city'] == selectedCityFilter).toList();
    }
  }

  Future<void> deleteTruck(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('confirm_delete_title'.tr()),
        content: Text('confirm_delete_msg'.tr()),
        actions: [
          TextButton(
            child: Text('cancel'.tr()),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('delete'.tr()),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final response = await TruckOwnerService.deleteTruck(id, token);
      if (response.statusCode == 200) {
        _showMessage('truck_deleted_success'.tr());
        fetchTrucks();
      } else {
        _showMessage('failed_to_delete_truck'.tr());
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
        title: Text('my_trucks'.tr(),
            style: const TextStyle(fontSize: 22, color: Colors.black)),
        backgroundColor: const Color.fromARGB(255, 255, 136, 0),
      ),
      body: AuthBackground(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedCityFilter,
                      hint: Text('filter_by_city'.tr()),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: null,
                          child: Text('all'.tr()),
                        ),
                        ...supportedCities.map((cityKey) => DropdownMenuItem(
                              value: cityKey,
                              child: Text(cityKey.tr()),
                            ))
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedCityFilter = value;
                          applyFilter();
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: filteredTrucks.isEmpty
                          ? Center(child: Text('no_trucks_found'.tr()))
                          : ListView.builder(
                              itemCount: filteredTrucks.length,
                              itemBuilder: (context, index) {
                                final truck = filteredTrucks[index];
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
                                              getFullImageUrl(
                                                  truck['logo_image_url'])),
                                          radius: 25,
                                        ),
                                        title: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              truck['truck_name'] ?? '',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            if ((truck['description'] ?? '')
                                                .isNotEmpty)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 4),
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                '${'cuisine'.tr()}: ${truck['cuisine_type'] ?? ''}'),
                                            Text(
                                                '${'address'.tr()}: ${truck['location']?['address_string'] ?? ''}'),
                                            Text(
                                                '${'city'.tr()}: ${truck['city'] ?? 'not_specified'.tr()}'),
                                            Text(
                                              '${'hours'.tr()}: ${truck['operating_hours']?['open'] ?? '--'} - ${truck['operating_hours']?['close'] ?? '--'}',
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
                                                final result =
                                                    await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) =>
                                                        EditTruckPage(
                                                            truck: truck),
                                                  ),
                                                );
                                                if (result == true) {
                                                  fetchTrucks();
                                                }
                                              },
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                  Icons.delete_outline,
                                                  color: Colors.redAccent),
                                              onPressed: () =>
                                                  deleteTruck(truck['_id']),
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
                                                  builder: (_) =>
                                                      ManageMenuPage(
                                                    truckId: truck['_id'],
                                                  ),
                                                ),
                                              );
                                            },
                                            icon: const Icon(
                                                Icons.restaurant_menu),
                                            label: Text('manage_menu'.tr()),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors.deepOrange,
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
                  ],
                ),
              ),
      ),
    );
  }
}
