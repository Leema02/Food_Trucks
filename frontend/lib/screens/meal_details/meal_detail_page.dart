import 'package:flutter/material.dart';

class MealDetailPage extends StatelessWidget {
  final String image;
  final String name;
  final String price;

  const MealDetailPage({
    super.key,
    required this.image,
    required this.name,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Stack(
              children: [
                Image.asset(image,
                    width: double.infinity, height: 250, fit: BoxFit.cover),
                Positioned(
                  top: 16,
                  left: 16,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold)),
                  Text("by Restaurant",
                      style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                  const SizedBox(height: 8),
                  Text("\$$price",
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(Icons.remove_circle_outline, size: 30),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor:
                              Colors.white, // 👈 makes the text white
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        child: const Text("Add To Bag"),
                      ),
                      const Icon(Icons.add_circle_outline, size: 30),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const TabBarSection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TabBarSection extends StatelessWidget {
  const TabBarSection({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: const [
          TabBar(
            labelColor: Colors.orange,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.orange,
            tabs: [
              Tab(text: "DETAILS"),
              Tab(text: "Review"),
            ],
          ),
          SizedBox(
            height: 100,
            child: TabBarView(
              children: [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                      "This meal is freshly made with the best ingredients..."),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("⭐️⭐️⭐️⭐️ Person: Amazing taste!"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
