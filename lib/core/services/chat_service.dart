import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  Future<void> sendMessage(String receiverID, String message) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception("No authenticated user found.");
      }

      final String currentUserID = currentUser.uid;
      final Timestamp timestamp = Timestamp.now();

      Map<String, dynamic> newMessage = {
        'senderID': currentUserID,
        'receiverID': receiverID,
        'message': message,
        'timestamp': timestamp,
        'isRead': false,
        'type': 'text',
      };

      List<String> ids = [currentUserID, receiverID];
      ids.sort();
      String chatroomID = ids.join("_");

      // Add to Firestore
      await _firestore
          .collection("chat_rooms")
          .doc(chatroomID)
          .collection("messages")
          .add(newMessage);

      // TODO: Update last message in chat_rooms document for list view optimization if needed
    } catch (e) {
      print("Error sending message: $e");
      rethrow;
    }
  }

  // Get messages stream
  Stream<QuerySnapshot> getMessages(String otherUserID) {
    String currentUserID = _auth.currentUser!.uid;
    List<String> ids = [currentUserID, otherUserID];
    ids.sort();
    String chatroomID = ids.join("_");

    return _firestore
        .collection("chat_rooms")
        .doc(chatroomID)
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }

  // Get last message
  Future<String> getLastMessage(
      String currentUserID, String otherUserID) async {
    List<String> ids = [currentUserID, otherUserID];
    ids.sort();
    String chatroomID = ids.join("_");

    try {
      final snapshot = await _firestore
          .collection("chat_rooms")
          .doc(chatroomID)
          .collection("messages")
          .orderBy("timestamp", descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first['message'] as String;
      } else {
        return "Start your conversation";
      }
    } catch (e) {
      return "Start your conversation";
    }
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(String otherUserID) async {
    try {
      String currentUserID = _auth.currentUser!.uid;
      List<String> ids = [currentUserID, otherUserID];
      ids.sort();
      String chatroomID = ids.join("_");

      final messages = await _firestore
          .collection("chat_rooms")
          .doc(chatroomID)
          .collection("messages")
          .where('receiverID', isEqualTo: currentUserID)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (var doc in messages.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (e) {
      print('Error marking messages as read: $e');
    }
  }
}
