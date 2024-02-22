import 'package:cloud_firestore/cloud_firestore.dart';

class Users {
  final Timestamp createdAt;
  final String email;
  final String userId;
  final String username;
  final String bio;
  final String userImage;

  Users({
    required this.createdAt,
    required this.email,
    required this.userId,
    required this.username,
    required this.bio,
    required this.userImage,
  });

  static Users fromJson(Map<String, dynamic> json) => Users(
        createdAt: json['created_at'] ?? Timestamp.now(),
        email: json['email'] ?? '',
        userId: json['user_id'] ?? '',
        username: json['username'] ?? '',
        bio: json['bio'] ?? '',
        userImage: json['user_image'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'created_at': createdAt,
        'email': email,
        'user_id': userId,
        'username': username,
        'bio': bio,
        'user_image': userImage,
      };
}
