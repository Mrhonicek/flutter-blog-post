import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String messageId;
  final String senderId;
  final String receiverId;
  final String senderEmail;
  final String message;
  final Timestamp timestamp;

  Message({
    required this.messageId,
    required this.senderId,
    required this.receiverId,
    required this.senderEmail,
    required this.message,
    required this.timestamp,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      messageId: json['message_id'] ?? '',
      senderId: json['sender_id'] ?? '',
      receiverId: json['receiver_id'] ?? '',
      senderEmail: json['sender_email'] ?? '',
      message: json['message'] ?? '',
      timestamp: json['timestamp'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message_id': messageId,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'sender_email': senderEmail,
      'message': message,
      'timestamp': timestamp,
    };
  }
}
