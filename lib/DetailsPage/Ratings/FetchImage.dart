import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  FirestoreService._();
  static final FirestoreService instance = FirestoreService._();

  Future<String?> fetchImageUrl(String productName) async {
    try {
      final collectionRef = FirebaseFirestore.instance.collection('Products');

      final querySnapshot = await collectionRef
          .where('Name', isEqualTo: productName)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        print("❌ No document found in Firestore for: $productName");
        return null;
      }

      final docData = querySnapshot.docs.first.data();

      // Check if "ImageUrl" exists in Firestore
      if (!docData.containsKey("ImageUrl")) {
        print("⚠️ 'ImageUrl' field missing in Firestore for: $productName");
        return null;
      }

      final dynamic imageUrlData = docData["ImageUrl"];

      if (imageUrlData is List) {
        if (imageUrlData.isNotEmpty && imageUrlData[0] is String) {
          return imageUrlData[0] as String;
        } else {
          print("⚠️ 'ImageUrl' list is empty or contains invalid data.");
          return null;
        }
      } else if (imageUrlData is String) {
        return imageUrlData;
      } else {
        print("⚠️ Unexpected 'ImageUrl' format: $imageUrlData");
      }
    } catch (e) {}

    print("⚠️ Returning null - Image not found for: $productName");
    return null;
  }
}
