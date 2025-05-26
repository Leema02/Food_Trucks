import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:myapp/screens/truckOwner/manageMenu/addMenuItem.dart';
import 'package:myapp/screens/truckOwner/manageMenu/editMenuItem.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/menu_service.dart';
import 'package:easy_localization/easy_localization.dart';

class ManageMenuPage extends StatefulWidget {
  final String truckId;
  const ManageMenuPage({super.key, required this.truckId});

  @override
  State<ManageMenuPage> createState() => _ManageMenuPageState();
}

class _ManageMenuPageState extends State<ManageMenuPage> {
  List<dynamic> menuItems = [];
  bool isLoading = true;
  String? token;

  String getFullImageUrl(String path) {
    return path.startsWith('http') ? path : 'http://10.0.2.2:5000$path';
  }

  @override
  void initState() {
    super.initState();
    _loadTokenAndFetchMenu();
  }

  Future<void> _loadTokenAndFetchMenu() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');
    await fetchMenuItems();
  }

  Future<void> fetchMenuItems() async {
    try {
      final response = await MenuService.getMenuItems(widget.truckId);

      if (response.statusCode == 200) {
        setState(() {
          menuItems = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        print("Failed to load menu items: ${response.body}");
      }
    } catch (e) {
      print("Error fetching menu items: $e");
    }
  }

  Future<void> deleteMenuItem(String itemId) async {
    if (token == null) return;

    final response = await MenuService.deleteMenuItem(itemId, token!);
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("item_deleted".tr())),
      );
      await fetchMenuItems();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("failed_to_delete_item".tr())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 202, 138),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 136, 0),
        foregroundColor: Colors.black,
        title: Text('my_menu'.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      AddMenuItemPage(truckId: widget.truckId),
                ),
              );
              if (result == true) {
                fetchMenuItems();
              }
            },
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : menuItems.isEmpty
              ? const Center(child: Text('No menu items found.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: menuItems.length,
                  itemBuilder: (context, index) {
                    final item = menuItems[index];

                    final bool isVegan = item['isVegan'] == true;
                    final bool isSpicy = item['isSpicy'] == true;
                    final int? calories = item['calories'];

                    // Subtitle content builder
                    List<String> tags = [];
                    if (isVegan) tags.add('🌱 Vegan');
                    if (isSpicy) tags.add('🌶️ Spicy');
                    if (calories != null) tags.add('$calories cal');

                    final subtitle = [
                      "${item['category']} • \$${item['price'].toString()}",
                      if (tags.isNotEmpty) tags.join(' • ')
                    ].join('\n');

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      child: ListTile(
                        leading: item['image_url'] != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  getFullImageUrl(item['image_url']),
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Icon(Icons.fastfood, size: 30),
                        title: Text(
                          item['name'] ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          subtitle,
                          style: const TextStyle(fontSize: 14),
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      EditMenuItemPage(item: item),
                                ),
                              ).then((result) {
                                if (result == true) fetchMenuItems();
                              });
                            } else if (value == 'delete') {
                              deleteMenuItem(item['_id']);
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'edit',
                              child: Text('edit'.tr()),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Text('delete'.tr()),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
