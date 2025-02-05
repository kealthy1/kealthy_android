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
        doc.data().containsKey('messages')
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
      final timestamp = DateTime.now();

      final querySnapshot =
          await collection.where('ticketId', isEqualTo: ticketId).get();

      if (querySnapshot.docs.isEmpty) {
        await collection.add({
          'ticketId': ticketId,
          'messages': [
            {
              'text': text,
              'isUser': true,
              'timestamp': timestamp,
            }
          ],
        });
      } else {
        final docId = querySnapshot.docs.first.id;

        final docSnapshot = await collection.doc(docId).get();
        final docData = docSnapshot.data();

        if (docData == null || !docData.containsKey('messages')) {
          await collection.doc(docId).set({
            'messages': [
              {
                'text': text,
                'isUser': true,
                'timestamp': timestamp, 
              }
            ],
          }, SetOptions(merge: true));
        } else {
          await collection.doc(docId).update({
            'messages': FieldValue.arrayUnion([
              {
                'text': text,
                'isUser': true,
                'timestamp': timestamp, 
              }
            ]),
          });
        }
      }
    } catch (e) {
      print('Error sending message: $e');
      
    }
  }
}