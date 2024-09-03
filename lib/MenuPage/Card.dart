import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../DetailsPage/HomePage.dart';
import '../Services/Fetchimage.dart';
import 'menu_item.dart';

class MenuItemCard extends StatelessWidget {
  final MenuItem menuItem;

  const MenuItemCard(this.menuItem, {super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          CupertinoModalPopupRoute(
            builder: (context) => HomePage(menuItem: menuItem),
          ),
        );
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: FutureBuilder<File>(
                    future:
                        CustomCacheManager().getSingleFile(menuItem.imageUrl),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            color: Colors.grey[300],
                          ),
                        );
                      }
                      if (snapshot.hasError) {
                        return const Center(child: Icon(Icons.error));
                      }
                      if (snapshot.hasData) {
                        return Image.file(snapshot.data!);
                      }
                      return const Center(child: Icon(Icons.error));
                    },
                  )),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    menuItem.name,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₹${menuItem.price.toStringAsFixed(0)}',
                        style:
                            const TextStyle(fontSize: 16, color: Colors.black),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.favorite_border,
                          color: Colors.red,
                        ),
                        onPressed: () {},
                      ),
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
