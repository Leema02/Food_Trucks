import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:myapp/constant/colors.dart';

class HomeBottomNavBar extends StatelessWidget {
  final Function(int) onTabSelected;
  final int currentIndex;

  const HomeBottomNavBar({
    super.key,
    required this.onTabSelected,
    required this.currentIndex,
  });
  Color getColor(int index) =>
      index == currentIndex ? AppColors.orangeColor : Colors.grey;

  @override
  Widget build(BuildContext context) {
    final double navBarWidth = MediaQuery.of(context).size.width * 0.85;

    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      child: SizedBox(
        height: 60,
        child: Center(
          child: SizedBox(
            width: navBarWidth,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(
                    FontAwesomeIcons.home,
                    color: currentIndex == 0
                        ? const Color.fromARGB(255, 255, 169, 39)
                        : Colors.grey.shade700,
                  ),
                  onPressed: () => onTabSelected(0),
                ),
                IconButton(
                  icon: Icon(
                    FontAwesomeIcons.binoculars,
                    color: currentIndex == 1
                        ? Colors.orange
                        : Colors.grey.shade700,
                  ),
                  onPressed: () => onTabSelected(1),
                ),
                const SizedBox(width: 48), // space for FAB
                IconButton(
                  icon: Icon(
                    FontAwesomeIcons.shoppingCart,
                    color: currentIndex == 2
                        ? Colors.orange
                        : Colors.grey.shade700,
                  ),
                  onPressed: () => onTabSelected(2),
                ),
                IconButton(
                  icon: Icon(
                    FontAwesomeIcons.userAlt,
                    color: currentIndex == 3
                        ? Colors.orange
                        : Colors.grey.shade700,
                  ),
                  onPressed: () => onTabSelected(3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
