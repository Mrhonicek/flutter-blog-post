import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blog_post_project/components/functions.dart';
import 'package:flutter_blog_post_project/models/groupchat.dart';
import 'package:flutter_blog_post_project/pages/chat_page.dart';
import 'package:flutter_blog_post_project/pages/create_groupchat_page.dart';

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
        actions: [
          // This is the dropdown button with shadow
          PopupMenuButton<String>(
            onSelected: (value) {
              // Handle selection
              if (value == 'create_group_chat') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CreateGroupChatPage()),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'create_group_chat',
                child: Row(
                  children: [
                    Icon(Icons.add_circle_outline),
                    SizedBox(width: 10.0),
                    Text('Create Group Chat'),
                  ],
                ),
              ),
            ],
            color: Theme.of(context).colorScheme.primary,
            shadowColor: Theme.of(context).colorScheme.tertiary,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildUserList(),
          ),
          const Divider(
            thickness: 1, // Adjust divider thickness as needed
          ),
          Expanded(
            child: _buildGroupChatList(),
          ),
        ],
      ),
    );
  }

  Widget _buildUserListItem(DocumentSnapshot document) {
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

  Widget _buildGroupChatItem(DocumentSnapshot document) {
    GroupChat groupChat =
        GroupChat.fromJson(document.data()! as Map<String, dynamic>);

    // Check for membership
    bool isMember = groupChat.memberIds.contains(widget.currentUser.uid);

    return isMember
        ? Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color:
                      Theme.of(context).colorScheme.tertiary.withOpacity(0.6),
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
                child: const CircleAvatar(
                  radius:
                      25, // This radius is the radius of the picture in the circle avatar itself.
                  // TODO: Set group chat avatar if available
                  // backgroundImage: NetworkImage("placeholder-group-chat-image.jpg"),
                ),
              ),
              title: Text(groupChat.roomTitle,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.secondary,
                  )),
              subtitle: Text(
                  "Created by ${groupChat.groupAdminId} on ${groupChat.createdAt.toDate()}"),
              onTap: () {
                // TODO: Navigate to group chat screen, passing relevant data
              },
            ),
          )
        : const SizedBox.shrink(); // Display nothing for non-members
  }

  Widget _buildUserList() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection("Users").snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text("Error loading user list");
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        return ListView(
          children: snapshot.data!.docs
              .map<Widget>((doc) => _buildUserListItem(doc))
              .toList(),
        );
      },
    );
  }

  Widget _buildGroupChatList() {
    return StreamBuilder(
      stream:
          FirebaseFirestore.instance.collection("Group_Chat_Rooms").snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text("Error loading group chat rooms");
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return ListView(
          children: snapshot.data!.docs
              .map<Widget>((doc) => _buildGroupChatItem(doc))
              .toList(),
        );
      },
    );
  }

/*
  Future<String> fetchAdminUsername(String adminId) async {
    String adminName = ""; // Default value in case of errors

    try {
      DocumentSnapshot adminDoc = await FirebaseFirestore.instance
          .collection("Users")
          .doc(adminId)
          .get();
      if (adminDoc.exists) {
        Users adminUser =
            Users.fromJson(adminDoc.data()! as Map<String, dynamic>);
        adminName = adminUser.username;
      } else {
        print("Admin user document not found");
      }
    } catch (error) {
      print("Error fetching admin username: $error");
    }

    return adminName;
  }

  */
}
