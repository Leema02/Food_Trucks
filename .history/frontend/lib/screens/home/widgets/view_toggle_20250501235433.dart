import 'package:flutter/material.dart';
import 'package:myapp/core/constants/colors.dart';

class ViewToggle extends StatelessWidget {
  final bool showListView;
  final ValueChanged<bool> onToggle;

  const ViewToggle({
    super.key,
    required this.showListView,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade400,
              blurRadius: 8,
              spreadRadius: 1,
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildToggleButton("List View", true),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: VerticalDivider(color: Colors.black),
            ),
            _buildToggleButton("Map View", false),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleButton(String text, bool isListView) {
    return GestureDetector(
      onTap: () => onToggle(isListView),
      child: Text(
        text,
        style: TextStyle(
          color: showListView == isListView
              ? AppColors.orangeColor
              : AppColors.greyColor,
          fontWeight: FontWeight.w400,
          fontSize: 16,
        ),
      ),
    );
  }
}
