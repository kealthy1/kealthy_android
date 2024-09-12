import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../MenuPage/menu_item.dart';
import '../../Services/Fetchimage.dart';

class RecipeCard extends StatelessWidget {
  final DietItem dietItem;

  const RecipeCard({
    super.key,
    required this.dietItem,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: screenWidth * 0.4,
      margin: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20), 
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: CachedNetworkImage(
              imageUrl: dietItem.imageUrl,
              cacheManager: CustomCacheManager(),
              height: screenWidth * 0.5,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            bottom: 10, 
            left: 10, 
            child: Text(
              dietItem.name,
              style: const TextStyle(
                fontSize: 16, 
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RecipeCardList extends StatelessWidget {
  final List<DietItem> dietItems;

  const RecipeCardList({
    super.key,
    required this.dietItems,
  });

  @override
  Widget build(BuildContext context) {
    final filteredDietItems =
        dietItems.where((item) => item.category == 'Diets').toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filteredDietItems
            .map((dietItem) => RecipeCard(dietItem: dietItem))
            .toList(),
      ),
    );
  }
}
