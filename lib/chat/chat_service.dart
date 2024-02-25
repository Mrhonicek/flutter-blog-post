import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blog_post_project/components/functions.dart';
import 'package:flutter_blog_post_project/models/groupchat.dart';
import 'package:flutter_blog_post_project/models/message.dart';
import 'package:intl/intl.dart';

class ChatService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  Future<String> uploadFile(File file) async {
    final filename =
        '${generateRandomImageName(5)}-${file.path.split('/').last}';

    final path = 'images/$filename';
    final reference = FirebaseStorage.instance.ref().child(path);
    final uploadTask = reference.putFile(file);

    try {
      final snapshot = await uploadTask.whenComplete(() => {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (error) {
      // Handle any errors that occur during the upload process
      print('Error uploading file: $error');
      rethrow; // Rethrow the error to allow for further handling
    }
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

  // TODO: GROUP CHAT FUNCTION STARTS HERE=========================================

  Future<void> createGroupChat(String roomTitle, List<String> memberIds) async {
    final String currentUserId = _firebaseAuth.currentUser!.uid;
    // Generate a unique group chat ID
    final String groupId =
        FirebaseFirestore.instance.collection('Group_Chat_Rooms').doc().id;

    // Create a GroupChat object
    final groupChat = GroupChat(
      groupId: groupId,
      groupAdminId: currentUserId,
      roomTitle: roomTitle,
      memberIds: memberIds,
      createdAt: Timestamp.now(),
    );

    // Add the group chat to Firestore
    await _fireStore.collection('Group_Chat_Rooms').doc(groupId).set(
          groupChat.toJson(),
        );
  }

  // * SEND  GROUP MESSAGES
  Future<void> sendGroupMessage(
      String groupId, String message, File? file) async {
    final downloadUrl = file != null ? await uploadFile(file) : null;

    // Get current user info
    final String currentUserId = _firebaseAuth.currentUser!.uid;
    final String currentUserEmail = _firebaseAuth.currentUser!.email.toString();
    final Timestamp timestamp = Timestamp.now();

    // Format the timestamp for the message ID
    final DateFormat dateFormat = DateFormat('yyyy-MM-dd_HH:mm:ss');
    final String formattedTimestamp = dateFormat.format(timestamp.toDate());

    final String messageId =
        "${groupId}_${formattedTimestamp}_${generateRandomImageName(10)}";

    // Create a new message
    Message newMessage = Message(
      messageId: messageId,
      senderId: currentUserId,
      senderEmail: currentUserEmail,
      receiverId: groupId, // Replace with the group ID
      message: message,
      timestamp: timestamp,
      fileName: file?.path.split('/').last, // Optional: store filename
      imageUrl: downloadUrl,
    );

    // Add message to the "Messages" collection within the group chat document
    await _fireStore
        .collection("Group_Chat_Rooms")
        .doc(groupId)
        .collection("Messages")
        .doc(messageId) // Use the generated message ID
        .set(newMessage.toJson());
  }

  //! DELETE GROUP MESSAGE
  Future<void> deleteGroupMessage(String groupId, String messageId) async {
    try {
      // Access the "Messages" collection within the group chat document
      await _fireStore
          .collection("Group_Chat_Rooms")
          .doc(groupId)
          .collection("Messages")
          .doc(messageId)
          .delete();
    } catch (e) {
      // Handle any errors that occurred during the deletion process
      print("Error deleting message: $e");
    }
  }

  // ? RECEIVE GROUP MESSAGES
  Stream<QuerySnapshot> receiveGroupMessages(String groupId) {
    return _fireStore
        .collection("Group_Chat_Rooms")
        .doc(groupId)
        .collection("Messages")
        .orderBy("timestamp",
            descending: false) // Order by timestamp, ascending
        .snapshots();
  }
}
