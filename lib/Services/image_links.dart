import 'package:cloud_firestore/cloud_firestore.dart';

class ImageLinks {
  static List<String> networkImageUrls = [];
  static List<String> textsForImages = [];

  static Future<void> fetchCarouselData() async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('Carousel').get();

      networkImageUrls.clear();
      textsForImages.clear();

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final List<String> images = List<String>.from(data['Image'] ?? []);
        final List<String> titles = List<String>.from(data['Title'] ?? []);

        for (int i = 0; i < images.length; i++) {
          if (i < titles.length) {
            networkImageUrls.add(images[i]);
            textsForImages.add(titles[i]);
          }
        }
      }
    } catch (e) {
      print("Error fetching carousel data: $e");
    }
  }
}
