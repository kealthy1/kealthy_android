import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../MenuPage/menu_item.dart';

class ImageHeader extends StatelessWidget {
  final MenuItem menuItem;

  const ImageHeader({required this.menuItem, super.key});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 10 / 9,
      child: CachedNetworkImage(
        imageUrl: menuItem.imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF273847),
          ),
        ),
        errorWidget: (context, url, error) => const Center(
          child: Icon(Icons.error, size: 50, color: Colors.red),
        ),
      ),
    );
  }
}
