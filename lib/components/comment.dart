import 'package:flutter/material.dart';

class Comment extends StatelessWidget {
  final String commentContent;
  final String user;
  final String time;
  const Comment({
    super.key,
    required this.commentContent,
    required this.user,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        children: [
          // ? comment content
          Text(commentContent),

          // ? user's name and time
          Row(
            children: [
              Text(user),
              const Text(" • "),
              Text(time),
            ],
          ),
        ],
      ),
    );
  }
}
