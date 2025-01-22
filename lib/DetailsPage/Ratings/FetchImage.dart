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

      if (querySnapshot.docs.isNotEmpty) {
        final docData = querySnapshot.docs.first.data();

        if (docData['ImageUrl'] is List) {
          final List<dynamic> imageUrlArray = docData['ImageUrl'];

          if (imageUrlArray.isNotEmpty) {
            return imageUrlArray[0] as String;
          }
        }
      }
    } catch (e) {
      print("Error fetching imageUrl for product $productName: $e");
    }

    return null; 
  }
}
