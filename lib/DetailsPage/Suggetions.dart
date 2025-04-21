import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import '../MenuPage/menu_item.dart';
import '../Services/Cache.dart';
import 'HomePage.dart';

class FirestoreData {
  final String id;
  final String name;
  final String qty;
  final String imageUrl;

  FirestoreData({
    required this.id,
    required this.name,
    required this.qty,
    required this.imageUrl,
  });

  factory FirestoreData.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    return FirestoreData(
      id: doc.id,
      name: data?['Name'] ?? '',
      qty: data?['Qty'] ?? '',
      imageUrl: data?['ImageUrl'] is List<dynamic> &&
              (data?['ImageUrl'] as List).isNotEmpty
          ? (data?['ImageUrl'] as List<dynamic>)[0]
          : '',
    );
  }
}

final menuItemsProvider = FutureProvider<List<MenuItem>>((ref) async {
  final querySnapshot =
      await FirebaseFirestore.instance.collection('Products').get();
  return querySnapshot.docs
      .map((doc) => MenuItem.fromFirestore(doc.data()))
      .toList();
});

class Suggestions extends ConsumerWidget {
  final MenuItem menuItem;

  const Suggestions({
    super.key,
    required this.menuItem,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menuItemsAsync = ref.watch(menuItemsProvider);

    return menuItemsAsync.when(
      data: (menuItems) => _buildContent(context, menuItems, ref),
      loading: () => Center(child: SizedBox.shrink()),
      error: (error, stackTrace) => SizedBox.shrink(),
    );
  }

  Widget _buildContent(
      BuildContext context, List<MenuItem> menuItems, WidgetRef ref) {
    final filteredItems = menuItems.where((item) {
      final isSameName =
          item.name.trim().toLowerCase() == menuItem.name.trim().toLowerCase();
      final isDifferentEAN = item.EAN != menuItem.EAN;
      return isSameName && isDifferentEAN;
    }).toList();

    final double containerWidth = MediaQuery.of(context).size.width * 0.15;
    final double containerHeight = MediaQuery.of(context).size.width * 0.15;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (filteredItems.isNotEmpty)
          Text(
            "Select Size",
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        if (filteredItems.isNotEmpty)
          SizedBox(
            height: containerHeight + 50,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: filteredItems.map((item) {
                  return _buildItemCard(
                      context, item, containerWidth, containerHeight, ref);
                }).toList(),
              ),
            ),
          ),
        if (filteredItems.isEmpty) SizedBox.shrink(),
        SizedBox(height: 15),
        _buildDetailsWidget(menuItem),
      ],
    );
  }

  Widget _buildDetailsWidget(MenuItem item) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              overflow: TextOverflow.ellipsis,
              "Brand:",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(width: 15),
            Text(
              item.brandName,
              style: TextStyle(
                overflow: TextOverflow.ellipsis,
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
      ],
    );
  }

  Widget _buildItemCard(BuildContext context, MenuItem item, double width,
      double height, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        // ignore: unused_result
        ref.refresh(menuItemsProvider);
        print(
          item.qty,
        );
        Navigator.pushReplacement(
          context,
          CupertinoModalPopupRoute(
            builder: (context) => HomePage(menuItem: item),
          ),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: width,
            height: height,
            margin: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: CachedNetworkImage(
                cacheManager: CustomCacheManager(),
                imageUrl: item.imageUrls[0],
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey.shade300,
                  child: Center(
                    child: Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        color: Colors.grey[300],
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                      ),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => SizedBox.shrink(),
              ),
            ),
          ),
          SizedBox(
            width: width,
            child: Column(
              children: [
                Text(
                  overflow: TextOverflow.ellipsis,
                  item.name,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  overflow: TextOverflow.ellipsis,
                  item.qty,
                  style: GoogleFonts.poppins(
                    fontSize: 9,
                    color: Colors.grey.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
