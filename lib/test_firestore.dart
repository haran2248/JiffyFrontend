import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final firestore = FirebaseFirestore.instance;

  // We don't know the exact IDs, so let's query the chat_rooms collection
  // to see what documents exist.
  final snapshot = await firestore.collection('chat_rooms').get();

  print("Found ${snapshot.docs.length} chat rooms.");

  for (var doc in snapshot.docs) {
    print("Chat Room ID: ${doc.id}");

    // Check messages
    final messages = await doc.reference.collection('messages').get();
    print("  Contains ${messages.docs.length} messages.");

    for (var msg in messages.docs) {
      print("  Message: ${msg.data()}");
    }
  }
}
