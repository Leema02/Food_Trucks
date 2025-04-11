import 'package:flutter/material.dart';
import 'package:myapp/screens/meal_details/meal_detail_page.dart'; // Make sure this path matches your file structure

class Cart extends StatefulWidget {
  const Cart({super.key});

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> with TickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, String>> foods = [
    {
      'name': 'Rice and meat',
      'price': '130.00',
      'rate': '4.8',
      'clients': '150',
      'image': 'assets/image/plate-003.png'
    },
    {
      'name': 'Vegan food',
      'price': '400.00',
      'rate': '4.2',
      'clients': '150',
      'image': 'assets/image/plate-007.png'
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  Widget renderList(List<Map<String, String>> data, {bool showReview = false}) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: data.length,
      itemBuilder: (BuildContext context, int index) {
        final food = data[index];

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MealDetailPage(
                  image: food['image']!,
                  name: food['name']!,
                  price: food['price']!,
                ),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 10.0),
            child: Card(
              child: Row(
                children: [
                  Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(food['image']!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(food['name']!),
                              if (!showReview) const Icon(Icons.delete_outline),
                            ],
                          ),
                          Text('\$${food['price']}'),
                          if (showReview)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(food['rate']!),
                                  const Text(
                                    'Give your review',
                                    style: TextStyle(color: Colors.orange),
                                  ),
                                ],
                              ),
                            )
                          else
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                const Icon(Icons.remove),
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 3, horizontal: 12),
                                  color: Colors.orange,
                                  child: const Text('Add To 2',
                                      style: TextStyle(color: Colors.white)),
                                ),
                                const Icon(Icons.add, color: Colors.orange),
                              ],
                            )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cart")),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            indicatorColor: Colors.orange,
            labelColor: Colors.black,
            tabs: const [
              Tab(text: 'Add Food'),
              Tab(text: 'Tracking Order'),
              Tab(text: 'Done Order'),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: TabBarView(
                controller: _tabController,
                children: [
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        renderList(foods),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            padding: const EdgeInsets.symmetric(
                                vertical: 15.0, horizontal: 35.0),
                          ),
                          onPressed: () {},
                          child: const Text('CHECKOUT',
                              style: TextStyle(color: Colors.white)),
                        )
                      ],
                    ),
                  ),
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        renderList(foods),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.location_searching,
                              color: Colors.white),
                          label: const Text('View Tracking Order',
                              style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            padding: const EdgeInsets.symmetric(
                                vertical: 15.0, horizontal: 25.0),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SingleChildScrollView(
                    child: renderList(foods, showReview: true),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
