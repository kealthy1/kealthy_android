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
    double screenWidth = MediaQuery.of(context).size.width;
    double defaultIconSize = screenWidth < 400 ? 24 : 30;
    double selectedIconSize = defaultIconSize + 10;
    double bottomNavBarHeight = 65.0;

    return Container(
      height: bottomNavBarHeight,
      decoration: const BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                    size: isSelected ? selectedIconSize : defaultIconSize,
                    color: isSelected ? Colors.white : Colors.grey,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.title ?? '',
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey,
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
