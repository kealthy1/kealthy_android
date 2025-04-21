import 'package:cached_network_image/cached_network_image.dart';
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
    final screenHeight = MediaQuery.of(context).size.height;
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
                  child: SizedBox(
                    height: screenHeight * 0.1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          menuItem.name,
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Spacer(),
                        Row(
                          children: [
                            Text(
                              '₹ ${menuItem.price.toStringAsFixed(0)}/-',
                              style: GoogleFonts.radioCanada(
                                fontSize: 16,
                                color: Colors.green,
                              ),
                            ),
                            Spacer(),
                            Text(
                              overflow: TextOverflow.ellipsis,
                              menuItem.qty,
                              style: GoogleFonts.poppins(
                                textStyle: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w400),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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
                          height: 46,
                          width: 38,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 4.0),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 201, 82, 74),
                          ),
                          alignment: Alignment.center,
                          child: // Put this where you currently build the “OUT OF STOCK” label
                              Column(
                            mainAxisSize: MainAxisSize.min,
                            children: menuItem.SOH == 0
                                /* ───────────── SOLD‑OUT ───────────── */
                                ? [
                                    Text('OUT',
                                        style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontSize: 6,
                                            fontWeight: FontWeight.bold)),
                                    Text('OF',
                                        style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontSize: 7,
                                            fontWeight: FontWeight.bold)),
                                    Text('STOCK',
                                        style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontSize: 6,
                                            fontWeight: FontWeight.bold)),
                                  ]
                                /* ───────────── LOW‑STOCK ───────────── */
                                : [
                                    Text('ONLY',
                                        style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontSize: 6,
                                            fontWeight: FontWeight.bold)),
                                    Text(
                                        //menuItem.SOH.toString(),
                                        menuItem.SOH.toStringAsFixed(0),
                                        style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontSize: 7,
                                            fontWeight: FontWeight.bold)),
                                    Text('LEFT',
                                        style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontSize: 6,
                                            fontWeight: FontWeight.bold)),
                                  ],
                          )),
                    ),
                  )
                : const SizedBox.shrink(),
          )
        ],
      ),
    );
  }
}
