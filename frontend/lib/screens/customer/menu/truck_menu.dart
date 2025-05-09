import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:myapp/screens/customer/menu/menu_card.dart';

class TruckMenuPage extends StatefulWidget {
  final String truckId;

  const TruckMenuPage({super.key, required this.truckId});

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
    fetchMenu();
  }

  Future<void> fetchMenu() async {
    try {
      final response = await http.get(
        Uri.parse("http://192.168.10.7:5000/api/menu/${widget.truckId}"),
      );

      if (response.statusCode == 200) {
        setState(() {
          menuItems = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = "HTTP ${response.statusCode}";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error: $e";
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
          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : menuItems.isEmpty
                  ? const Center(child: Text("No menu items found 😢"))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: menuItems.length,
                      itemBuilder: (context, index) {
                        return MenuCard(item: menuItems[index]);
                      },
                    ),
    );
  }
}
