import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountPage extends StatefulWidget {
  final String role; // "customer" or "truck owner"
  const AccountPage({super.key, required this.role});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  String name = '';
  String email = '';

  @override
  void initState() {
    super.initState();
    loadUserInfo();
  }

  Future<void> loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('user_name') ?? 'Guest';
      email = prefs.getString('user_email') ?? 'email@example.com';
    });
  }

  void logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7), // Light gray background
      appBar: AppBar(
        title: const Text("My Account"),
        backgroundColor: const Color.fromARGB(255, 255, 148, 33),
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.white,
                    child:
                        Icon(Icons.person, size: 40, color: Colors.deepOrange),
                  ),
                  const SizedBox(height: 12),
                  Text(name,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600)),
                  Text(email,
                      style:
                          const TextStyle(fontSize: 14, color: Colors.black54)),
                ],
              ),
            ),
            const SizedBox(height: 30),
            _buildAccountButton(
              icon: Icons.edit,
              label: "Edit Profile",
              onTap: () => Navigator.pushNamed(context, '/edit-profile'),
            ),
            _buildAccountButton(
              icon: Icons.lock,
              label: "Change Password",
              onTap: () => Navigator.pushNamed(context, '/change-password'),
            ),
            _buildAccountButton(
              icon: Icons.support_agent,
              label: "Contact Support",
              onTap: () {
                // Future support screen
              },
            ),
            _buildAccountButton(
              icon: Icons.logout,
              label: "Logout",
              onTap: logout,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(2, 2),
          )
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.deepOrange),
        title: Text(label,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
