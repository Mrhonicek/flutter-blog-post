import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blog_post_project/models/message.dart';

class ChatService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  Future<String> uploadFile(File file) async {
    // Create a reference to the file in Cloud Storage
    final storageRef = FirebaseStorage.instance.ref().child(
        'images/${DateTime.now().millisecondsSinceEpoch}/${file.path.split('/').last}');

    // Upload the file
    final uploadTask = storageRef.putFile(file);
    final snapshot = await uploadTask!.whenComplete(() => {});

    // Get the download URL
    final downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  // * Send Messages
  Future<void> sendMessage(
    String receiverId,
    String message,
    File? file,
  ) async {
    final downloadUrl = file != null ? await uploadFile(file) : null;

    // get currentUser info
    final String currentUserId = _firebaseAuth.currentUser!.uid;
    final String currentUserEmail = _firebaseAuth.currentUser!.email.toString();
    final Timestamp timestamp = Timestamp.now();

    // generate a unique messageId
    final messageId =
        FirebaseFirestore.instance.collection('Chat_Rooms').doc().id;

    // create a new message
    Message newMessage = Message(
      messageId: messageId,
      senderId: currentUserId,
      senderEmail: currentUserEmail,
      receiverId: receiverId,
      message: message,
      timestamp: timestamp,
      fileName: file?.path.split('/').last, // Optional: store filename
      imageUrl: downloadUrl,
    );

    // construct chat room id (unique)
    List<String> ids = [currentUserId, receiverId];
    ids.sort();
    String chatRoomId = ids.join("_");

    // add new message to database with messageId as the document ID
    await _fireStore
        .collection("Chat_Rooms")
        .doc(chatRoomId)
        .collection("Messages")
        .doc(messageId) // set the messageId as the document ID
        .set(
          newMessage.toJson(),
        );
  }

  // ! Delete Messages
  Future<void> deleteMessage(
      String userId, String otherUserId, String messageId) async {
    try {
      List<String> ids = [userId, otherUserId];
      ids.sort();
      String chatRoomId = ids.join("_");

      await _fireStore
          .collection("Chat_Rooms")
          .doc(chatRoomId)
          .collection("Messages")
          .doc(messageId)
          .delete();
    } catch (e) {
      // Handle any errors that occurred during the deletion process
      print("Error deleting message: $e");
    }
  }

  // ? Receive Messages
  Stream<QuerySnapshot> getMessages(String userId, String otherUserId) {
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join("_");

    return _fireStore
        .collection("Chat_Rooms")
        .doc(chatRoomId)
        .collection("Messages")
        .orderBy(
          "timestamp",
          descending: false,
        )
        .snapshots();
  }
}
