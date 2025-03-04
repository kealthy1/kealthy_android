import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import '../DetailsPage/HomePage.dart';
import '../DetailsPage/NutritionInfo.dart';
import '../DetailsPage/Product_Rating.dart';
import '../Services/Cache.dart';
import 'menu_item.dart';

class MenuItemCard extends ConsumerWidget {
  final MenuItem menuItem;

  const MenuItemCard(this.menuItem, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final averageStarsAsync = ref.watch(averageStarsProvider(menuItem.name));
    return GestureDetector(
      onTap: () {
        // ignore: unused_result
        ref.refresh(productRatingProvider(menuItem.name));
        FocusScope.of(context).unfocus();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(menuItem: menuItem),
          ),
        );
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                  child: AspectRatio(
                    aspectRatio: 0.9,
                    child: CachedNetworkImage(
                      cacheManager: CustomCacheManager(),
                      width: double.infinity,
                      fit: BoxFit.cover,
                      imageUrl: menuItem.imageUrls.isNotEmpty
                          ? menuItem.imageUrls[0]
                          : '',
                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          color: Colors.grey[300],
                        ),
                      ),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          overflow: TextOverflow.ellipsis,
                          menuItem.name,
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      averageStarsAsync.when(
                        data: (averageStars) => Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            ...List.generate(5, (index) {
                              if (index < averageStars.floor()) {
                                return Icon(Icons.star_outlined,
                                    color: Colors.amber, size: 12);
                              } else if (index == averageStars.floor() &&
                                  averageStars % 1 != 0) {
                                return const Icon(Icons.star_half,
                                    color: Colors.amber, size: 12);
                              } else {
                                return const Icon(
                                    Icons.star_border_purple500_rounded,
                                    color: Colors.amber,
                                    size: 12);
                              }
                            }),
                            SizedBox(
                              width: 3,
                            ),
                            Expanded(
                              child: Text(
                                '${averageStars.toStringAsFixed(1)} Ratings',
                                style: GoogleFonts.poppins(
                                  color: Colors.black87,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                        loading: () => const SizedBox.shrink(),
                        error: (error, stack) => const SizedBox.shrink(),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '₹ ${menuItem.price.toStringAsFixed(0)}/-',
                        style: GoogleFonts.radioCanada(
                          fontSize: 16,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: menuItem.SOH < 4
                ? Transform.translate(
                    offset: const Offset(-1, -1),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(10),
                      ),
                      child: Container(
                        height: 40,
                        width: 35,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 4.0),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 201, 82, 74),
                        ),
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Only",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 6,
                              ),
                            ),
                            Text(
                              menuItem.SOH.toStringAsFixed(0),
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Left",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          )
        ],
      ),
    );
  }
}
