import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Services/Notifications/FromFirestore.dart';
import '../NutritionInfo.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shimmer/shimmer.dart';
import 'FetchImage.dart';
import 'Providers.dart';
import 'Show_Review.dart';

class ProductReviewWidget extends ConsumerWidget {
  final List<String> productNames;
  final String orderId;
  const ProductReviewWidget(
      {super.key, required this.productNames, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderStatus = ref.watch(orderStatusProvider);

    return orderStatus.when(
        data: (shouldShowReview) {
          final notifier = ref.read(rateProductProvider.notifier);

          if (productNames.isEmpty) {
            return SizedBox.shrink();
          }

          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(centerTitle: true,
              automaticallyImplyLeading: false,
              surfaceTintColor: Colors.white,
              title: Text(
                "Share Your Feedback",
                style: GoogleFonts.poppins(color: const Color(0xFF273847)),
              ),
              backgroundColor: Colors.white,
            ),
            body: ListView.builder(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemCount: productNames.length,
              itemBuilder: (context, index) {
                final productName = productNames[index];
                final averageStarsAsync =
                    ref.watch(averageStarsProvider(productName));

                return FutureBuilder<String?>(
                  future: FirestoreService.instance.fetchImageUrl(productName),
                  builder: (context, snapshot) {
                    final imageUrl = snapshot.data;

                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        color: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.grey.shade300,
                                        ),
                                      ),
                                      child: imageUrl != null
                                          ? ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              child: CachedNetworkImage(
                                                imageUrl: imageUrl,
                                                fit: BoxFit.fill,
                                                placeholder: (context, url) =>
                                                    Shimmer.fromColors(
                                                  baseColor: Colors.grey[300]!,
                                                  highlightColor:
                                                      Colors.grey[100]!,
                                                  child: Container(
                                                    color: Colors.grey[300],
                                                  ),
                                                ),
                                                errorWidget: (context, error,
                                                        stackTrace) =>
                                                    const Icon(
                                                  Icons.image_not_supported,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            )
                                          : const Icon(
                                              Icons.image_not_supported,
                                              color: Colors.grey,
                                              size: 40,
                                            ),
                                    ),
                                    const SizedBox(width: 16),
                                    Flexible(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            productName,
                                            style: GoogleFonts.poppins(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          averageStarsAsync.when(
                                            data: (averageStars) =>
                                                averageStars > 0
                                                    ? Row(
                                                        children: [
                                                          Row(
                                                            children:
                                                                List.generate(
                                                              averageStars
                                                                  .ceil(),
                                                              (i) => Icon(
                                                                i < averageStars
                                                                    ? Icons.star
                                                                    : (i - averageStars <
                                                                            1
                                                                        ? Icons
                                                                            .star_half
                                                                        : Icons
                                                                            .star_border),
                                                                color: Colors
                                                                    .amber,
                                                                size: 15,
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width: 5),
                                                          Text(
                                                            "${averageStars.toStringAsFixed(1)} Rating",
                                                            style: GoogleFonts
                                                                .poppins(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 15,
                                                            ),
                                                          ),
                                                        ],
                                                      )
                                                    : const SizedBox.shrink(),
                                            loading: () =>
                                                const SizedBox.shrink(),
                                            error: (err, _) =>
                                                const SizedBox.shrink(),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                TextField(
                                  cursorColor: Colors.black,
                                  minLines: 1,
                                  maxLines: null,
                                  decoration: InputDecoration(
                                    hintText: 'Love It or Not? Let Us Know!',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.grey.shade100,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onChanged: (value) {
                                    notifier.updateFeedback(productName, value);
                                  },
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: List.generate(5, (starIndex) {
                                    final productState = ref.watch(
                                            rateProductProvider)[productName] ??
                                        const RateProductState();

                                    return IconButton(
                                      icon: Icon(
                                        starIndex < productState.selectedRating
                                            ? Icons.star
                                            : Icons.star_border,
                                        color: Colors.amber,
                                      ),
                                      onPressed: () {
                                        ref
                                            .read(rateProductProvider.notifier)
                                            .updateRating(
                                              productName,
                                              starIndex + 1,
                                            );
                                      },
                                    );
                                  }),
                                ),
                                const SizedBox(height: 10),
                                Center(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      backgroundColor: const Color(0xFF273847),
                                    ),
                                    onPressed: ref
                                                .watch(rateProductProvider)[
                                                    productName]
                                                ?.isLoading ??
                                            false
                                        ? null
                                        : () async {
                                            final prefs =
                                                await SharedPreferences
                                                    .getInstance();
                                            final customerName =
                                                prefs.getString("name");
                                            notifier.submitReview(
                                              customerName:
                                                  customerName ?? 'User',
                                              productName: productName,
                                              apiUrl:
                                                  "https://api-jfnhkjk4nq-uc.a.run.app/rate",
                                              onSuccess: (message) async {
                                                Fluttertoast.showToast(
                                                  msg:
                                                      "Thanks for sharing your thoughts with us!",
                                                  toastLength:
                                                      Toast.LENGTH_SHORT,
                                                  gravity: ToastGravity.BOTTOM,
                                                  backgroundColor:
                                                      const Color(0xFF273847),
                                                  textColor: Colors.white,
                                                  fontSize: 12.0,
                                                );

                                                await deleteProductFromOrder(
                                                    orderId, productName);
                                                // ignore: unused_result
                                                ref.refresh(
                                                    firestoreNotificationProvider);
                                                Navigator.pop(context);
                                              },
                                              onError: (error) {},
                                            );
                                          },
                                    child: ref
                                                .watch(rateProductProvider)[
                                                    productName]
                                                ?.isLoading ??
                                            false
                                        ? const CircularProgressIndicator(
                                            strokeWidth: 1,
                                            valueColor: AlwaysStoppedAnimation(
                                                Colors.white),
                                          )
                                        : Text(
                                            'Post Review',
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.poppins(
                                              color: Colors.white,
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
        loading: () => Center(
            child: LoadingAnimationWidget.inkDrop(
                color: Color(0xFF273847), size: 60)),
        error: (e, _) => SizedBox.shrink());
  }
}

Future<void> deleteProductFromOrder(String orderId, String productName) async {
  final firestore = FirebaseFirestore.instance;

  try {
    // Query the document where orderId matches
    final querySnapshot = await firestore
        .collection('Notifications')
        .where('order_id', isEqualTo: orderId)
        .get();

    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      List<dynamic> productNames = List.from(data['product_names'] ?? []);

      if (productNames.contains(productName)) {
        if (productNames.length > 1) {
          // Remove the specific product name
          productNames.remove(productName);

          // Update the document with the modified list
          await firestore.collection('Notifications').doc(doc.id).update({
            'product_names': productNames,
          });

          print('Product "$productName" removed from orderId: $orderId');
        } else {
          // If only one product remains, delete the whole document
          await firestore.collection('Notifications').doc(doc.id).delete();
          print(
              'Last product found! Deleting entire notification for orderId: $orderId');
        }
      }
    }
  } catch (e) {
    print('Error deleting product: $e');
  }
}
