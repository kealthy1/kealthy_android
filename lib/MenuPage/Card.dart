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

    return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            CupertinoModalPopupRoute(
              builder: (context) => HomePage(menuItem: menuItem),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                  child: CachedNetworkImage(
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
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        menuItem.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('₹ ${menuItem.price.toStringAsFixed(0)}/-',
                          style: const TextStyle(
                              fontSize: 18, fontFamily: "Poppins")),
                      Row(
                        children: [
                          const Icon(Icons.energy_savings_leaf_rounded,
                              size: 18, color: Colors.green),
                          const SizedBox(width: 4),
                          Text(menuItem.nutrients,
                              style: const TextStyle(
                                  fontSize: 13, fontFamily: "Poppins")),
                        ],
                      ),
                      const SizedBox(height: 4),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
