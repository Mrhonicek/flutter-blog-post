import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blog_post_project/components/comment_widget.dart';
import 'package:flutter_blog_post_project/components/textfield.dart';
import 'package:intl/intl.dart';

class CommentsPage extends StatefulWidget {
  final String blogId;
  final String postImage;
  final String username;
  final Timestamp createdAt;
  final User currentUser;

  const CommentsPage({
    Key? key,
    required this.blogId,
    required this.postImage,
    required this.username,
    required this.createdAt,
    required this.currentUser,
  }) : super(key: key);

  @override
  State<CommentsPage> createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  final TextEditingController _commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          'Comments',
          style: TextStyle(
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
      ),
      body: Column(
        children: [
          // TODO: Display Post Image, Username, and CreatedAt
          SizedBox(
            child: Image.network(
              widget.postImage, // Make sure this contains a valid image URL
              height: 300,
              width: double.infinity,
              fit: BoxFit.fill,
              errorBuilder: (context, error, stackTrace) {
                // Handle errors, e.g., display a default offline image
                return Image.asset(
                  'images/no-image.png',
                  height: 300,
                  width: double.infinity,
                  fit: BoxFit.fitHeight,
                );
              },
            ),
          ),

          // TODO: Post information
          Text.rich(
            TextSpan(
              text: 'Posted by ',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.secondary,
              ),
              children: [
                TextSpan(
                  text: widget.username,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                ),
                TextSpan(
                  text:
                      ' on ${DateFormat.yMMMMd().format(widget.createdAt.toDate())}',
                  // Adjust the date format according to your preferences
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),

          // TODO:  Display Comments
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('Blogs')
                  .doc(widget.blogId)
                  .collection("Comments")
                  .orderBy(
                    'created_at',
                    descending: false,
                  )
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                var comments = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    var comment =
                        comments[index].data() as Map<String, dynamic>;
                    return CommentWidget(
                      comment: comment,
                      onDelete: (commentId) {
                        deleteComment(comment['comment_id']);
                      },
                      currentUserUid: widget.currentUser.uid,
                    );
                  },
                );
              },
            ),
          ),

          // Add Comment Input
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              boxShadow: [
                BoxShadow(
                  color:
                      Theme.of(context).colorScheme.tertiary.withOpacity(0.4),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: const Offset(0, -2), // changes the shadow position
                ),
              ],
            ),
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: MyTextField(
                    controller: _commentController,
                    hintText: "Add a comment",
                    obscureText: false,
                    icon: Icons.chat_outlined,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.send,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  onPressed: () {
                    // Implement logic to add comment to Firestore
                    addComment();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void deleteComment(String commentId) {
    FirebaseFirestore.instance
        .collection('Blogs')
        .doc(widget.blogId)
        .collection("Comments")
        .doc(commentId)
        .delete();
  }

  Future<String> getCurrentUsername() async {
    // Fetch the current user's username from Firestore
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(widget.currentUser.uid)
        .get();

    return userDoc.get('username');
  }

  void addComment() async {
    // Implement logic to add comment to Firestore
    String commentText = _commentController.text.trim();
    if (commentText.isNotEmpty) {
      // Fetch the current user's username
      String currentUsername = await getCurrentUsername();
      final commentId = FirebaseFirestore.instance
          .collection('Blogs')
          .doc(widget.blogId)
          .collection("Comments")
          .doc()
          .id;
      final firestoreInstance = FirebaseFirestore.instance;

      await firestoreInstance
          .collection('Blogs')
          .doc(widget.blogId)
          .collection("Comments")
          .doc(commentId)
          .set({
        'user_id': widget.currentUser.uid,
        'comment_id': commentId,
        'content': commentText,
        'username': currentUsername,
        'created_at': Timestamp.now(),
      });

      // Clear the text field after adding a comment
      _commentController.clear();
    }
  }
}
