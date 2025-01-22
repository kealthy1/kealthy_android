import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:google_fonts/google_fonts.dart';

class ProductRating {
  final String productName;
  final List<Rating> ratings;
  final int totalRatings;
  final String averageStars;

  ProductRating({
    required this.productName,
    required this.ratings,
    required this.totalRatings,
    required this.averageStars,
  });

  factory ProductRating.fromJson(Map<String, dynamic> json) {
    return ProductRating(
      productName: json['productName'],
      ratings:
          (json['ratings'] as List).map((e) => Rating.fromJson(e)).toList(),
      totalRatings: json['totalRatings'],
      averageStars: json['averageStars'],
    );
  }
}

class Rating {
  final String customerName;
  final int starCount;
  final String feedback;

  Rating({
    required this.customerName,
    required this.starCount,
    required this.feedback,
  });

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      customerName: json['customerName'],
      starCount: json['starCount'],
      feedback: json['feedback'],
    );
  }
}

final productRatingProvider = FutureProvider.autoDispose
    .family<ProductRating?, String>((ref, productName) async {
  final dio = Dio();

  final url = 'https://api-jfnhkjk4nq-uc.a.run.app/rate/$productName';

  try {
    final response = await dio.get(
      url,
      options: Options(
        validateStatus: (status) {
          return status != null && status < 500;
        },
      ),
    );

    if (response.statusCode == 200) {
      return ProductRating.fromJson(response.data);
    } else {
      debugPrint(
          'Error: Received status code ${response.statusCode} for product "$productName".');
      debugPrint('Response: ${response.data}');
      return null;
    }
  } catch (e) {
    debugPrint('Exception for product "$productName": $e');
    return null;
  }
});

class RatingsPage extends ConsumerWidget {
  final String productName;

  const RatingsPage({super.key, required this.productName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ratingsData = ref.watch(productRatingProvider(productName));

    return ratingsData.when(
      data: (productRating) {
        if (productRating == null || productRating.ratings.isEmpty) {
          return SizedBox.shrink();
        }

        return SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Ratings & Reviews",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: productRating.ratings.map((rating) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Divider(),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: Colors.blue,
                              child: Text(
                                rating.customerName[0].toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  rating.customerName,
                                  style: GoogleFonts.montserrat(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Row(
                                  children: List.generate(
                                    rating.starCount,
                                    (index) => const Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                      size: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const SizedBox(width: 5),
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 8),
                                  if (rating.feedback.isNotEmpty)
                                    Text(
                                      rating.feedback,
                                      style: GoogleFonts.poppins(
                                        color: Colors.black54,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Divider(),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => SizedBox.shrink(),
      error: (error, stackTrace) {
        debugPrint('Error for product "$productName": $error');
        debugPrint('StackTrace: $stackTrace');

        return SizedBox.shrink();
      },
    );
  }
}
