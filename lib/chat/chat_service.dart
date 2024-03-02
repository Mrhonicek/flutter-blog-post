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
      print('Error uploading file: $error');
      rethrow;
    }
  }

  Future<void> sendMessage(
    String receiverId,
    String message,
    File? file,
  ) async {
    final downloadUrl = file != null ? await uploadFile(file) : null;

    final String currentUserId = _firebaseAuth.currentUser!.uid;
    final String currentUserEmail = _firebaseAuth.currentUser!.email.toString();
    final Timestamp timestamp = Timestamp.now();

    final messageId =
        FirebaseFirestore.instance.collection('Chat_Rooms').doc().id;

    Message newMessage = Message(
      messageId: messageId,
      senderId: currentUserId,
      senderEmail: currentUserEmail,
      receiverId: receiverId,
      message: message,
      timestamp: timestamp,
      fileName: file?.path.split('/').last,
      imageUrl: downloadUrl,
    );

    List<String> ids = [currentUserId, receiverId];
    ids.sort();
    String chatRoomId = ids.join("_");

    await _fireStore
        .collection("Chat_Rooms")
        .doc(chatRoomId)
        .collection("Messages")
        .doc(messageId)
        .set(
          newMessage.toJson(),
        );
  }

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
    final String groupId =
        FirebaseFirestore.instance.collection('Group_Chat_Rooms').doc().id;

    final groupChat = GroupChat(
      groupId: groupId,
      groupAdminId: currentUserId,
      roomTitle: roomTitle,
      memberIds: memberIds,
      createdAt: Timestamp.now(),
      groupImage: '',
    );

    await _fireStore.collection('Group_Chat_Rooms').doc(groupId).set(
          groupChat.toJson(),
        );
  }

  // ? UPDATE GROUP MEMBERS
  Future<void> updateGroupMembers(
      String groupId, List<String> newMemberIds) async {
    try {
      await _fireStore
          .collection('Group_Chat_Rooms')
          .doc(groupId)
          .update({'member_ids': newMemberIds});
    } catch (error) {
      print(error);
      rethrow;
    }
  }

  Future<void> sendGroupMessage(
      String groupId, String message, File? file) async {
    final downloadUrl = file != null ? await uploadFile(file) : null;

    final String currentUserId = _firebaseAuth.currentUser!.uid;
    final String currentUserEmail = _firebaseAuth.currentUser!.email.toString();
    final Timestamp timestamp = Timestamp.now();

    final DateFormat dateFormat = DateFormat('yyyy-MM-dd_HH:mm:ss');
    final String formattedTimestamp = dateFormat.format(timestamp.toDate());

    final String messageId =
        "${groupId}_${formattedTimestamp}_${generateRandomImageName(10)}";

    Message newMessage = Message(
      messageId: messageId,
      senderId: currentUserId,
      senderEmail: currentUserEmail,
      receiverId: groupId,
      message: message,
      timestamp: timestamp,
      fileName: file?.path.split('/').last,
      imageUrl: downloadUrl,
    );

    await _fireStore
        .collection("Group_Chat_Rooms")
        .doc(groupId)
        .collection("Messages")
        .doc(messageId)
        .set(newMessage.toJson());
  }

  Future<void> deleteGroupMessage(String groupId, String messageId) async {
    try {
      await _fireStore
          .collection("Group_Chat_Rooms")
          .doc(groupId)
          .collection("Messages")
          .doc(messageId)
          .delete();
    } catch (e) {
      print("Error deleting message: $e");
    }
  }

  Future<void> deleteGroupChat(String groupId) async {
    try {
      await _fireStore.collection('Group_Chat_Rooms').doc(groupId).delete();
    } catch (e) {
      print("Error deleting group chat: $e");
    }
  }

  // ? RECEIVE GROUP MESSAGES
  Stream<QuerySnapshot> receiveGroupMessages(String groupId) {
    return _fireStore
        .collection("Group_Chat_Rooms")
        .doc(groupId)
        .collection("Messages")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }
}
