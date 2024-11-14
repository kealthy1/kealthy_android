// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:kealthy/Cart/Cart_Items.dart';
// import '../Services/FirestoreCart.dart';

// class CartContainer extends ConsumerStatefulWidget {
//   const CartContainer({super.key});

//   @override
//   ConsumerState<CartContainer> createState() => _CartContainerState();
// }

// class _CartContainerState extends ConsumerState<CartContainer> {
//   @override
//   void initState() {
//     super.initState();
//     ref.read(addCartProvider.notifier).fetchCartItems();
//   }

//   @override
//   Widget build(BuildContext context) {
//     double screenWidth = MediaQuery.of(context).size.width;
//     double screenHeight = MediaQuery.of(context).size.height;

//     return Padding(
//       padding: const EdgeInsets.all(4.0),
//       child: GestureDetector(
//         onTap: () {
//           Navigator.push(
//               context,
//               CupertinoModalPopupRoute(
//                 builder: (context) => const ShowCart(),
//               ));
//         },
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               height: screenHeight * 0.1,
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(12),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.grey.withOpacity(0.5),
//                     spreadRadius: 2,
//                     blurRadius: 5,
//                     offset: const Offset(0, 3),
//                   ),
//                 ],
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Flexible(
//                       child: Row(
//                         children: [
//                           Consumer(
//                             builder: (context, ref, child) {
//                               final cartItems = ref.watch(addCartProvider);
//                               final firstItemImageUrl = cartItems.isNotEmpty
//                                   ? cartItems[0].imageUrl
//                                   : '';

//                               return CircleAvatar(
//                                 backgroundColor: Colors.white,
//                                 radius: 25,
//                                 backgroundImage: firstItemImageUrl.isNotEmpty
//                                     ? CachedNetworkImageProvider(
//                                         firstItemImageUrl)
//                                     : const AssetImage("assets/Kealthy.jpeg")
//                                         as ImageProvider,
//                               );
//                             },
//                           ),
//                           SizedBox(width: screenWidth * 0.03),
//                           Flexible(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Consumer(
//                                   builder: (context, ref, child) {
//                                     final cartItems =
//                                         ref.watch(addCartProvider);

//                                     final itemName = cartItems.isNotEmpty
//                                         ? cartItems[0].name
//                                         : '';

//                                     return Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         Text(
//                                           itemName,
//                                           style: TextStyle(
//                                             fontSize: screenWidth * 0.05,
//                                             color: Colors.black,
//                                           ),
//                                           overflow: TextOverflow.ellipsis,
//                                           maxLines: 1,
//                                         ),
//                                         const Text(
//                                           'Show full history',
//                                           style: TextStyle(
//                                             fontSize: 12,
//                                             color: Colors.grey,
//                                           ),
//                                         ),
//                                       ],
//                                     );
//                                   },
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         SizedBox(
//                           width: screenWidth * 0.30,
//                           height: screenHeight * 0.05,
//                           child: ElevatedButton(
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.green,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                             ),
//                             onPressed: () {
//                               Navigator.push(
//                                   context,
//                                   CupertinoModalPopupRoute(
//                                     builder: (context) => const ShowCart(),
//                                   ));
//                             },
//                             child: Consumer(
//                               builder: (context, ref, child) {
//                                 final cartItemCount =
//                                     ref.watch(addCartProvider).length;
//                                 return Center(
//                                   child: Text(
//                                     'Cart ($cartItemCount)',
//                                     textAlign: TextAlign.center,
//                                     style: const TextStyle(
//                                       color: Colors.white,
//                                       fontSize: 14,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                 );
//                               },
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         IconButton(
//                           icon: const Icon(
//                             CupertinoIcons.multiply_circle,
//                             color: Colors.grey,
//                           ),
//                           onPressed: () {
//                             final cartItems = ref.read(addCartProvider);
//                             if (cartItems.isNotEmpty) {
//                               ref
//                                   .read(addCartProvider.notifier)
//                                   .deleteAllItemsFromCart();
//                             }
//                           },
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';      
import '../Cart/Cart_Items.dart';
import '../Services/FirestoreCart.dart';

class CartVisibilityNotifier extends StateNotifier<bool> {
  CartVisibilityNotifier() : super(true);

  void setVisible(bool isVisible) {
    state = isVisible;
  }
}

final cartVisibilityProvider =
    StateNotifierProvider<CartVisibilityNotifier, bool>((ref) {
  return CartVisibilityNotifier();
});

final cartItemCountProvider = StateProvider<int>((ref) => 0);

class CartContainer extends ConsumerWidget {
  const CartContainer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.read(sharedPreferencesCartProvider.notifier).loadCartItems();
    final cartItems = ref.watch(sharedPreferencesCartProvider);
    final totalItems =
        cartItems.fold<int>(0, (sum, item) => sum + item.quantity);
    if (totalItems == 0) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 95,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.green.shade400,
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10), topRight: Radius.circular(10))),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Cart',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
              Text(
                '$totalItems item(s) selected',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                CupertinoModalPopupRoute(
                  builder: (context) => const ShowCart(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Go to Cart',
              style: TextStyle(
                color: Colors.green,
                fontFamily: "Poppins",
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(
              CupertinoIcons.delete,
              color: Colors.white,
            ),
             onPressed: () {
              final cartItems = ref.read(sharedPreferencesCartProvider);
              if (cartItems.isNotEmpty) {
                ref.read(sharedPreferencesCartProvider.notifier).clearCart();
              }
            },
          ),
        ],
      ),
    );
  }
}