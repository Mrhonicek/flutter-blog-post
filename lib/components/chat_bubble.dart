import 'package:flutter/material.dart';
import 'package:flutter_blog_post_project/components/image_bubble.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final String? imageUrl;

  const ChatBubble({
    super.key,
    required this.message,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return ImageBubble(
        imageUrl: imageUrl!,
      );
    } else {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Theme.of(context).colorScheme.primary,
        ),
        child: Text(
          message,
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
      );
    }
  }
}
