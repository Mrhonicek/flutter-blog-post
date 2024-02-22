import 'package:cloud_firestore/cloud_firestore.dart';

class Blogs {
  final String authorId;
  final String blogId;
  final String content;
  final Timestamp createdAt;
  final String postImage;
  final String title;
  final List<String> likes; // New property

  Blogs({
    required this.authorId,
    required this.blogId,
    required this.content,
    required this.createdAt,
    required this.postImage,
    required this.title,
    required this.likes, // Initialize the list in the constructor
  });

  static Blogs fromJson(Map<String, dynamic> json) => Blogs(
        authorId: json['author_id'] ?? '',
        blogId: json['blog_id'] ?? '',
        content: json['content'] ?? '',
        createdAt: json['created_at'] ?? Timestamp.now(),
        postImage: json['post_image'] ?? '',
        title: json['title'] ?? '',
        likes:
            List<String>.from(json['likes'] ?? []), // Initialize the likes list
      );

  Map<String, dynamic> toJson() => {
        'author_id': authorId,
        'blog_id': blogId,
        'content': content,
        'created_at': createdAt,
        'post_image': postImage,
        'title': title,
        'likes': likes, // Include likes in the JSON representation
      };
}
