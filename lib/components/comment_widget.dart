import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blog_post_project/models/users.dart';
import 'functions.dart';

class CommentWidget extends StatelessWidget {
  final Map<String, dynamic> comment;
  final Function(String) onDelete;
  final String currentUserUid;

  const CommentWidget({
    Key? key,
    required this.comment,
    required this.onDelete,
    required this.currentUserUid,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Users?>(
      stream: getUserStream(comment['user_id']),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active &&
            snapshot.hasData) {
          Users? userData = snapshot.data;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Container(
                  margin: const EdgeInsets.only(right: 8, left: 10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                  child: CircleAvatar(
                    radius:
                        22, // Change this radius for the width of the circular border
                    backgroundColor: Theme.of(context).colorScheme.tertiary,
                    child: CircleAvatar(
                      radius:
                          20, // This radius is the radius of the picture in the circle avatar itself.
                      backgroundImage: userData!.userImage.isNotEmpty &&
                              userData.userImage != ""
                          ? NetworkImage(userData.userImage)
                          : const AssetImage('images/no_user_image.png')
                              as ImageProvider<Object>?,
                    ),
                  ),
                ),

                // Comment Content
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        constraints: const BoxConstraints(
                          maxWidth: 290, // Set your desired maximum width
                        ),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userData.username,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.tertiary,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              comment['content'],
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 7, top: 4),
                        child: Text(
                          formatCommentTimestamp(comment['created_at']),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.tertiary,
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Delete Button
                if (currentUserUid == comment['user_id'])
                  IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                    onPressed: () {
                      showAlertDialogOnDelete(context, comment['comment_id']);
                    },
                  ),
              ],
            ),
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  Stream<Users?> getUserStream(String userId) {
    try {
      return FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .snapshots()
          .map((snapshot) {
        if (snapshot.exists) {
          Map<String, dynamic> userData =
              snapshot.data() as Map<String, dynamic>;
          return Users.fromJson(userData);
        } else {
          return null; // User with the provided userID not found
        }
      });
    } catch (error) {
      print("Error getting user data: $error");
      return Stream.value(null);
    }
  }

  showAlertDialogOnDelete(BuildContext context, String messageId) {
    Widget cancelButton = TextButton(
      child: Text(
        "Cancel",
        style: TextStyle(
          color: Theme.of(context).colorScheme.tertiary,
        ),
      ),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    Widget continueButton = TextButton(
      child: Text(
        "Continue",
        style: TextStyle(
          color: Theme.of(context).colorScheme.tertiary,
        ),
      ),
      onPressed: () {
        Navigator.of(context).pop();
        onDelete(messageId);
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text(
        "Question",
        style: TextStyle(
          color: Theme.of(context).colorScheme.tertiary,
        ),
      ),
      content: Text(
        "Are you sure you want to delete this comment?",
        style: TextStyle(
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
