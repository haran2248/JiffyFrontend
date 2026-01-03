import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

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
      debugPrint("Error sending message: $e");
      rethrow;
    }
  }

  // Get messages stream
  Stream<QuerySnapshot> getMessages(String otherUserID) {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      // Return a failing stream instead of throwing synchronously
      return Stream.error(Exception("No authenticated user found."));
    }
    String currentUserID = currentUser.uid;
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
  Future<Map<String, dynamic>?> getLastMessage(
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
        return snapshot.docs.first.data();
      } else {
        return null;
      }
    } catch (e) {
      debugPrint("Error fetching last message: $e");
      rethrow;
    }
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(String otherUserID) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception("No authenticated user found.");
      }

      String currentUserID = currentUser.uid;
      List<String> ids = [currentUserID, otherUserID];
      ids.sort();
      String chatroomID = ids.join("_");

      // Querying by isRead: false first to likely avoid composite index issues.
      // Then filtering by receiverID in memory to ensure we only update messages meant for us.
      final messages = await _firestore
          .collection("chat_rooms")
          .doc(chatroomID)
          .collection("messages")
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      bool hasUpdates = false;

      for (var doc in messages.docs) {
        // Ensure we only mark messages sent to US as read
        if (doc['receiverID'] == currentUserID) {
          batch.update(doc.reference, {'isRead': true});
          hasUpdates = true;
        }
      }

      if (hasUpdates) {
        await batch.commit();
      }
    } catch (e) {
      debugPrint('Error marking messages as read: $e');
      rethrow;
    }
  }
}
