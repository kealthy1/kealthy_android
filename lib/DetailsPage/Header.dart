import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../MenuPage/menu_item.dart';

class ImageCacheNotifier extends StateNotifier<Image?> {
  ImageCacheNotifier() : super(null);

  Future<void> cacheImage(String imageUrl, BuildContext context) async {
    await precacheImage(NetworkImage(imageUrl), context);

    state = Image.network(imageUrl);
  }
}

final imageCacheProvider =
    StateNotifierProvider<ImageCacheNotifier, Image?>((ref) {
  return ImageCacheNotifier();
});

class ImageHeader extends ConsumerWidget {
  final MenuItem menuItem;

  const ImageHeader({required this.menuItem, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    
    ref.watch(imageCacheProvider);

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(imageCacheProvider.notifier)
          .cacheImage(menuItem.imageUrl, context);
    });

    return Container(
      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
      child: Stack(
        children: [
          Center(
              child: CachedNetworkImage(
            imageUrl: menuItem.imageUrl,
            width: screenWidth * 0.5,
            height: screenHeight * 0.3,
            placeholder: (context, url) => SizedBox(
              width: screenWidth * 0.5,
              height: screenHeight * 0.3,
            ),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          )),
          // Align(
          //   alignment: Alignment.topRight,
          //   child: Padding(
          //     padding: EdgeInsets.all(screenWidth * 0.02),
          //     child: Stack(
          //       alignment: Alignment.topRight,
          //       children: [
          //         AddToCartAnimation(
          //           isAdded: isCartAnimationActive,
          //           child: IconButton(
          //             icon: const Icon(
          //               Icons.shopping_cart_outlined,
          //               size: 30,
          //             ),
          //             onPressed: () {
          //               Navigator.push(
          //                 context,
          //                 CupertinoModalPopupRoute(
          //                   builder: (context) => const ShowCart(),
          //                 ),
          //               );
          //             },
          //             color:
          //                 isCartAnimationActive ? Colors.black : Colors.white,
          //           ),
          //         ),
          //         Consumer(
          //           builder: (context, ref, child) {
          //             final cartItemCount = ref.watch(addCartProvider).length;
          //             return Positioned(
          //               top: 0,
          //               right: 0,
          //               child: Container(
          //                 padding: const EdgeInsets.only(top: 1),
          //                 decoration: BoxDecoration(
          //                   color: Colors.red,
          //                   borderRadius: BorderRadius.circular(10),
          //                 ),
          //                 constraints: const BoxConstraints(
          //                   minWidth: 15,
          //                   minHeight: 15,
          //                 ),
          //                 child: Center(
          //                   child: Text(
          //                     '$cartItemCount',
          //                     style: const TextStyle(
          //                       color: Colors.white,
          //                       fontSize: 10,
          //                     ),
          //                   ),
          //                 ),
          //               ),
          //             );
          //           },
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
