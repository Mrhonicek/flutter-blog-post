import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blog_post_project/components/functions.dart';
import 'package:flutter_blog_post_project/components/profile_text_box.dart';
import 'package:flutter_blog_post_project/models/users.dart';
import 'package:flutter_blog_post_project/pages/chat_pages/chat_page.dart';

class OtherUserProfilePage extends StatelessWidget {
  final User currentUser;
  final Map<String, dynamic> otherUserData;

  const OtherUserProfilePage({
    Key? key,
    required this.currentUser,
    required this.otherUserData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text("Profile Page"),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("Users")
            .doc(otherUserData['author_id'])
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final userData = snapshot.data!.data() as Map<String, dynamic>;
            final user = Users.fromJson(userData);

            return ListView(
              children: [
                const SizedBox(
                  height: 50,
                ),
                CircleAvatar(
                  radius: 70,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: CircleAvatar(
                    radius: 65,
                    backgroundImage:
                        user.userImage.isNotEmpty && user.userImage != ""
                            ? NetworkImage(user.userImage)
                            : const AssetImage('images/no_user_image.png')
                                as ImageProvider<Object>?,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  user.username,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.tertiary,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  otherUserData["email"],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.tertiary,
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.mail),
                  iconSize: 30,
                  color: Theme.of(context).colorScheme.tertiary,
                  onPressed: () {
                    goToPage(
                      context,
                      ChatPage(
                        username: otherUserData['username'],
                        receiverUserEmail: otherUserData['email'],
                        receiverUserId: otherUserData['author_id'],
                      ),
                    );
                  },
                ),
                const SizedBox(
                  height: 50,
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 25,
                  ),
                  child: Text(
                    'User Details',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.tertiary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                ProfileTextBox(
                  text: user.username,
                  sectionName: "Username",
                ),
                ProfileTextBox(
                  text: user.bio,
                  sectionName: "Bio",
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error${snapshot.error}',
              ),
            );
          } else {
            return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
