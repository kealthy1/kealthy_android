import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod/riverpod.dart';

final ticketIdProvider = StateProvider<String>((ref) => '');
final messagesProvider =
    StreamProvider.family<List<Map<String, dynamic>>, String>((ref, ticketId) {
  return FirebaseFirestore.instance
      .collection('Help')
      .where('ticketId', isEqualTo: ticketId)
      .snapshots()
      .map((snapshot) {
    if (snapshot.docs.isEmpty) return [];
    final doc = snapshot.docs.first;
    final messages =
        doc.data().containsKey('messages') // Check if 'messages' exists
            ? doc['messages'] as List<dynamic>
            : [];
    return messages.map((message) {
      return {
        'text': message['text'] ?? '',
        'isUser': message['isUser'] ?? false,
        'timestamp': message['timestamp']?.toDate(),
      };
    }).toList();
  });
});

final sendMessageProvider = Provider((ref) => SendMessageService());

class SendMessageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> sendMessage(String ticketId, String text) async {
    try {
      final collection = _firestore.collection('Help');
      final timestamp = DateTime.now(); // Use local timestamp

      // Find the document with the matching ticketId
      final querySnapshot =
          await collection.where('ticketId', isEqualTo: ticketId).get();

      if (querySnapshot.docs.isEmpty) {
        // Create a new document with the messages field
        await collection.add({
          'ticketId': ticketId,
          'messages': [
            {
              'text': text,
              'isUser': true,
              'timestamp': timestamp, // Use local timestamp here
            }
          ],
        });
      } else {
        // Update the existing document
        final docId = querySnapshot.docs.first.id;

        // Check if the 'messages' field exists
        final docSnapshot = await collection.doc(docId).get();
        final docData = docSnapshot.data();

        if (docData == null || !docData.containsKey('messages')) {
          // Initialize 'messages' field if it doesn't exist
          await collection.doc(docId).set({
            'messages': [
              {
                'text': text,
                'isUser': true,
                'timestamp': timestamp, // Use local timestamp here
              }
            ],
          }, SetOptions(merge: true));
        } else {
          // Append to the existing 'messages' array
          await collection.doc(docId).update({
            'messages': FieldValue.arrayUnion([
              {
                'text': text,
                'isUser': true,
                'timestamp': timestamp, // Use local timestamp here
              }
            ]),
          });
        }
      }
    } catch (e) {
      print('Error sending message: $e');
      throw Exception('Failed to send message.');
    }
  }
}