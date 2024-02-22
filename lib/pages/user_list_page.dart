import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blog_post_project/components/functions.dart';
import 'package:flutter_blog_post_project/pages/chat_page.dart';

class UserListPage extends StatefulWidget {
  final User currentUser;
  const UserListPage({
    super.key,
    required this.currentUser,
  });

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text('Message Users'),
        elevation: 4,
      ),
      body: _buildUserList(),
    );
  }

  Widget _buildUserListIndividualItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

    // * Display all users except the currentUser
    if (widget.currentUser.email != data["email"]) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.tertiary.withOpacity(0.6),
              spreadRadius: 2,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          tileColor: Colors
              .transparent, // Set to transparent to avoid overlapping with container color
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: CircleAvatar(
            radius:
                30, // Change this radius for the width of the circular border
            backgroundColor: Theme.of(context).colorScheme.tertiary,
            child: CircleAvatar(
              radius:
                  25, // This radius is the radius of the picture in the circle avatar itself.
              backgroundImage:
                  data["user_image"].isNotEmpty && data["user_image"] != ""
                      ? NetworkImage(data["user_image"])
                      : const AssetImage('images/no_user_image.png')
                          as ImageProvider<Object>?,
            ),
          ),
          trailing: Icon(
            Icons.mail,
            color: Theme.of(context).colorScheme.secondary,
          ),
          title: Text(
            data["username"],
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          subtitle: Text(
            data["email"],
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          onTap: () {
            goToPage(
              context,
              ChatPage(
                username: data["username"],
                receiverUserEmail: data["email"],
                receiverUserId: data["user_id"],
              ),
            );
          },
        ),
      );
    } else {
      return Container();
    }
  }

  Widget _buildUserList() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection("Users").snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text("Error loading snapshot");
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        return ListView(
          children: snapshot.data!.docs
              .map<Widget>((doc) => _buildUserListIndividualItem(doc))
              .toList(),
        );
      },
    );
  }
}
