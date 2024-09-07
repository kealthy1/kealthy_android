import 'package:flutter/material.dart';
import 'package:floating_bottom_navigation_bar/floating_bottom_navigation_bar.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final List<FloatingNavbarItem> navbarItems;
  final Function(int) onTap;

  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.navbarItems,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    double bottomNavBarHeight = 65.0;

    return Container(
      height: bottomNavBarHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border.all(
          color: Colors.grey, 
          width: 3.0, 
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: navbarItems.map((item) {
            bool isSelected = currentIndex == navbarItems.indexOf(item);
            return GestureDetector(
              onTap: () => onTap(navbarItems.indexOf(item)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    item.icon,
                    size: 30,
                    color: isSelected ? Colors.green : Colors.grey,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.title ?? '',
                    style: TextStyle(
                      color: isSelected ? Colors.green : Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
