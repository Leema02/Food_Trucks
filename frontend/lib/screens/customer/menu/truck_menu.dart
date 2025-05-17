import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:myapp/core/services/menu_service.dart';
import 'package:myapp/screens/customer/menu/menu_card.dart';

class TruckMenuPage extends StatefulWidget {
  final String truckId;
  final String truckCity;

  const TruckMenuPage({
    super.key,
    required this.truckId,
    required this.truckCity,
  });

  @override
  State<TruckMenuPage> createState() => _TruckMenuPageState();
}

class _TruckMenuPageState extends State<TruckMenuPage> {
  List<dynamic> menuItems = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchMenuItems();
  }

  Future<void> fetchMenuItems() async {
    try {
      final response = await MenuService.getMenuItems(widget.truckId);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          menuItems = data;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Server Error: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Connection Error: $e';
        isLoading = false;
      });
    }
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
              : menuItems.isEmpty
                  ? const Center(child: Text("No menu items found 😢"))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: menuItems.length,
                      itemBuilder: (context, index) {
                        return MenuCard(
                          item: menuItems[index],
                          truckId: widget.truckId,
                          truckCity: widget.truckCity, // ✅ passed properly
                        );
                      },
                    ),
    );
  }
}
