import 'package:flutter/material.dart';

class HomeBottomNavBar extends StatelessWidget {
  final Function(int) onTabSelected;
  final int currentIndex;

  const HomeBottomNavBar({
    super.key,
    required this.onTabSelected,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      elevation: 10,
      color: Colors.white,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildTabItem(
              icon: Icons.home,
              index: 0,
              currentIndex: currentIndex,
              onTap: onTabSelected,
            ),
            _buildTabItem(
              icon: Icons.travel_explore,
              index: 1,
              currentIndex: currentIndex,
              onTap: onTabSelected,
            ),
            const SizedBox(width: 40), // <-- empty space for floating button
            _buildTabItem(
              icon: Icons.shopping_cart,
              index: 2,
              currentIndex: currentIndex,
              onTap: onTabSelected,
            ),
            _buildTabItem(
              icon: Icons.person,
              index: 3,
              currentIndex: currentIndex,
              onTap: onTabSelected,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem({
    required IconData icon,
    required int index,
    required int currentIndex,
    required Function(int) onTap,
  }) {
    bool isSelected = index == currentIndex;
    return GestureDetector(
      onTap: () => onTap(index),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Icon(
          icon,
          color: isSelected ? Colors.orange : Colors.grey,
          size: 28,
        ),
      ),
    );
  }
}
