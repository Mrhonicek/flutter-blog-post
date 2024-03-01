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
  late TextEditingController _commentController;
  late ScrollController _scrollController;

  @override
  void initState() {
    // TODO: implement initState
    _commentController = TextEditingController();
    _scrollController = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

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
          _buildImage(),
          _buildCommentInfo(),
          _buildComment(context),
          _buildCommentInput(),
        ],
      ),
    );
  }

  Widget _buildImage() {
    return SizedBox(
      child: Image.network(
        widget.postImage,
        height: MediaQuery.of(context).size.height / 3,
        width: double.infinity,
        fit: BoxFit.fill,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            'images/no-image.png',
            height: MediaQuery.of(context).size.height / 3,
            width: double.infinity,
            fit: BoxFit.fitHeight,
          );
        },
      ),
    );
  }

  Widget _buildComment(BuildContext context) {
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Blogs')
            .doc(widget.blogId)
            .collection("Comments")
            .orderBy('created_at', descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final comments = snapshot.data!.docs;

          return ListView.builder(
            itemCount: comments.length,
            itemBuilder: (context, index) {
              final comment = comments[index].data() as Map<String, dynamic>;
              return CommentWidget(
                comment: comment,
                onDelete: (commentId) => deleteComment(comment['comment_id']),
                currentUserUid: widget.currentUser.uid,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCommentInput() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.tertiary.withOpacity(0.4),
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
    );
  }

  Widget _buildCommentInfo() {
    return Container(
      color: Theme.of(context).colorScheme.primary,
      width: double.infinity,
      child: Text.rich(
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
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            TextSpan(
              text:
                  ' on ${DateFormat.yMMMMd().format(widget.createdAt.toDate())}',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Theme.of(context).colorScheme.tertiary,
              ),
            ),
          ],
        ),
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
