import 'package:flutter/material.dart';
import 'package:myapp/screens/login/widgets/card_widget.dart';
import 'package:myapp/constant/colors.dart';
import 'package:myapp/screens/login/widgets/likebutton/LikeButton.dart';

class Account extends StatefulWidget {
  final String username;
  final String location;

  const Account({
    super.key,
    this.username = "Fernando Moraes",
    this.location = "Warsaw, Poland",
  });

  @override
  _AccountState createState() => _AccountState();
}

class _AccountState extends State<Account> with TickerProviderStateMixin {
  late TabController _tabController;
  bool switchValue = true;

  final List<Map<String, String>> favoriteFoods = [
    {
      'name': 'Tandoori Chicken',
      'price': '96.00',
      'rate': '4.9',
      'clients': '200',
      'image': 'assets/image/plate-001.png'
    },
    {
      'name': 'Salmon',
      'price': '40.50',
      'rate': '4.5',
      'clients': '168',
      'image': 'assets/image/plate-002.png'
    },
    {
      'name': 'Rice and meat',
      'price': '130.00',
      'rate': '4.8',
      'clients': '150',
      'image': 'assets/image/plate-003.png'
    }
  ];

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                const SizedBox(height: 10),
                const Text(
                  'Profile',
                  style: TextStyle(
                    fontSize: 18.0,
                    color: AppColors.orangeColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15),
                const CircleAvatar(
                  backgroundColor: Colors.blueGrey,
                  radius: 35.0,
                  child: Icon(Icons.person, size: 30.0, color: Colors.white),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.username,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 22.0),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.location_on,
                        size: 16.0, color: Colors.black54),
                    const SizedBox(width: 5),
                    Text(
                      widget.location,
                      style: const TextStyle(
                          fontSize: 14.0, color: Colors.black54),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    _buildStat('250K', 'Follower'),
                    _buildStat('500', 'Following'),
                    _buildStat('540', 'Taste Master'),
                  ],
                ),
                const SizedBox(height: 15),
                TabBar(
                  controller: _tabController,
                  indicatorColor: AppColors.orangeColor,
                  labelColor: AppColors.orangeColor,
                  unselectedLabelColor: Colors.black,
                  labelStyle: const TextStyle(fontSize: 16),
                  tabs: const [
                    Tab(text: 'Your Favorite'),
                    Tab(text: 'Account Setting'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      SingleChildScrollView(
                        child: _buildFavoriteList(context),
                      ),
                      SingleChildScrollView(child: _buildSettings(theme)),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStat(String value, String label) {
    return Column(
      children: <Widget>[
        Text(
          value,
          style: const TextStyle(fontSize: 18.0, color: Colors.grey),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 18.0, color: AppColors.orangeColor),
        ),
      ],
    );
  }

  Widget _buildFavoriteList(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: favoriteFoods.length,
        itemBuilder: (context, index) {
          final product = favoriteFoods[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: CardListWidget(
              image: product['image']!,
              foodName: product['name']!,
              foodDetail: "Popular Dish",
              foodTime: "30-40 min",
              vote: double.parse(product['rate']!),
              heartIcon: LikeButton(
                key: UniqueKey(),
                width: 70,
                onIconClicked: (isLike) {},
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSettings(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
      child: Column(
        children: [
          _buildSettingItem(Icons.location_on, 'Location', theme),
          _buildSettingItem(Icons.local_shipping, 'Shipping', theme),
          _buildSettingItem(Icons.account_balance_wallet, 'Payment', theme),
          _buildSwitchSettingItem('Location Tracking', theme),
          const SizedBox(height: 50),
          ListTile(
            leading: const Icon(Icons.power_settings_new, color: Colors.red),
            title: const Text('Logout', style: TextStyle(fontSize: 18)),
            onTap: () {
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/login',
                (route) => false,
              );
            },
          ),
          Divider(color: Colors.grey[300]),
        ],
      ),
    );
  }

  Widget _buildSettingItem(IconData icon, String title, ThemeData theme) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: Colors.green),
          title: Text(title, style: const TextStyle(fontSize: 18)),
        ),
        Divider(color: Colors.grey[300]),
      ],
    );
  }

  Widget _buildSwitchSettingItem(String title, ThemeData theme) {
    return Column(
      children: [
        ListTile(
          title: Text(title, style: const TextStyle(fontSize: 18)),
          trailing: Switch(
            value: switchValue,
            onChanged: (val) => setState(() => switchValue = val),
            activeColor: theme.primaryColor,
          ),
        ),
        Divider(color: Colors.grey[300]),
      ],
    );
  }
}
