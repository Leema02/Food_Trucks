import 'package:flutter/material.dart';
import 'package:myapp/screens/auth/widgets/auth_background.dart';

class ManageMenuPage extends StatelessWidget {
  const ManageMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> menuItems = [
      {
        'name': 'Falafel Wrap',
        'price': 4.99,
        'image': 'https://example.com/images/falafel.jpg',
        'description': 'Crispy falafel with tahini and pickles.',
      },
      {
        'name': 'Shawarma Plate',
        'price': 7.99,
        'image': 'https://example.com/images/shawarma.jpg',
        'description': 'Juicy chicken shawarma with fries.',
      },
    ];

    return AuthBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Manage Menu'),
          backgroundColor: Colors.orange,
          elevation: 0,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton.icon(
                icon:
                    const Icon(Icons.add, color: Colors.white), // ✅ icon color
                label: const Text(
                  'Add Menu Item',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                  ), // ✅ text color
                ),
                onPressed: () {
                  // TODO: action
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor:
                      Colors.white, // ✅ also sets icon/text by default
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Your Items',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: menuItems.length,
                  itemBuilder: (context, index) {
                    final item = menuItems[index];
                    return MenuItemCard(item: item);
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

class MenuItemCard extends StatelessWidget {
  final Map<String, dynamic> item;

  const MenuItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(item['image'],
              width: 60, height: 60, fit: BoxFit.cover),
        ),
        title: Text(item['name'],
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(item['description']),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('\$${item['price'].toStringAsFixed(2)}'),
            PopupMenuButton<String>(
              onSelected: (value) {
                // handle 'edit' or 'delete'
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit')),
                PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
