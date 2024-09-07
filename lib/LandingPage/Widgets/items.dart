import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rounded_background_text/rounded_background_text.dart';
import 'package:shimmer/shimmer.dart';
import '../../DetailsPage/HomePage.dart';
import '../../MenuPage/menu_item.dart';
import '../../Services/Fetchimage.dart';

class ItemCard extends ConsumerWidget {
  final MenuItem menuItem;
  final CustomCacheManager cacheManager = CustomCacheManager();

  ItemCard({super.key, required this.menuItem});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth * 0.9;
        final imageSize = cardWidth * 0.3;

        final showFullDescription =
            ref.watch(showFullDescriptionProvider(menuItem));

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HomePage(menuItem: menuItem),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: cardWidth,
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green),
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 5),
                        RoundedBackgroundText(
                          menuItem.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          backgroundColor: const Color.fromARGB(255, 89, 161, 91),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          showFullDescription
                              ? menuItem.description
                              : '${menuItem.description.substring(0, 50)}...',
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 12,
                          ),
                        ),
                        if (!showFullDescription)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
                            child: TextButton(
                              onPressed: () {
                                ref
                                    .read(showFullDescriptionProvider(menuItem)
                                        .notifier)
                                    .state = !showFullDescription;
                              },
                              child: const Text(
                                'Read More',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                        Text(
                          'Price:₹${menuItem.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          cacheManager: cacheManager,
                          imageUrl: menuItem.imageUrl,
                          height: imageSize,
                          width: imageSize,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Center(
                            child: Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: Container(
                                color: Colors.grey[300],
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Icon(
                            Icons.error,
                            size: imageSize,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          Text(
                            menuItem.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

final showFullDescriptionProvider = StateProvider.family<bool, MenuItem>(
  (ref, menuItem) => false,
);
