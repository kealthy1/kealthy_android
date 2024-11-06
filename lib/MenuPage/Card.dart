import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kealthy/DetailsPage/HomePage.dart';
import 'package:shimmer/shimmer.dart';
import 'menu_item.dart';

class MenuItemCard extends ConsumerWidget {
  final MenuItem menuItem;

  const MenuItemCard(this.menuItem, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double discountedPrice = menuItem.price * 0.8;
    double screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          CupertinoModalPopupRoute(
            builder: (context) => HomePage(menuItem: menuItem),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[300]!),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: 1),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CachedNetworkImage(
              height: 200,
              imageUrl: menuItem.imageUrl,
              width: double.infinity,
              placeholder: (context, url) => Center(
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    color: Colors.grey[300],
                  ),
                ),
              ),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          menuItem.name,
                          style: TextStyle(
                            fontSize: screenWidth * 0.060,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        "⭐ ${menuItem.rating.toStringAsFixed(1)}",
                        style: TextStyle(fontSize: screenWidth * 0.045),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.local_fire_department_outlined,
                          color: Colors.orange[600], size: 16),
                      const SizedBox(width: 4),
                      Text('${menuItem.kcal.toStringAsFixed(0)} cal',
                          style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: screenWidth * 0.035)),
                      const SizedBox(width: 10),
                      Icon(Icons.fitness_center,
                          color: Colors.green[800], size: 16),
                      const SizedBox(width: 4),
                      Text('${menuItem.protein.toStringAsFixed(0)}g protein',
                          style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: screenWidth * 0.035)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text('₹${discountedPrice.toStringAsFixed(0)}/-',
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: screenWidth * 0.04)),
                      const SizedBox(width: 10),
                      Text('₹${menuItem.price.toStringAsFixed(0)}',
                          style: TextStyle(
                              color: Colors.red[500],
                              decoration: TextDecoration.lineThrough,
                              fontSize: screenWidth * 0.035)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
