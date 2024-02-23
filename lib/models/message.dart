import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String messageId;
  final String senderId;
  final String receiverId;
  final String senderEmail;
  final String message;
  final Timestamp timestamp;

  final String? imageUrl; // Optional field
  final String? fileName; // Optional field

  Message({
    required this.messageId,
    required this.senderId,
    required this.receiverId,
    required this.senderEmail,
    required this.message,
    required this.timestamp,
    this.imageUrl,
    this.fileName,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      messageId: json['message_id'] ?? '',
      senderId: json['sender_id'] ?? '',
      receiverId: json['receiver_id'] ?? '',
      senderEmail: json['sender_email'] ?? '',
      message: json['message'] ?? '',
      timestamp: json['timestamp'] ?? Timestamp.now(),
      imageUrl: json['image_url'],
      fileName: json['file_name'],
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
      if (imageUrl != null) 'image_url': imageUrl,
      if (fileName != null) 'file_name': fileName,
    };
  }
}
