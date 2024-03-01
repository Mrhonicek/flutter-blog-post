import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blog_post_project/components/functions.dart';
import 'package:flutter_blog_post_project/components/textfield.dart';
import 'package:flutter_blog_post_project/models/groupchat.dart';
import 'package:flutter_blog_post_project/pages/chat_pages/chat_page.dart';
import 'package:flutter_blog_post_project/pages/chat_pages/create_groupchat_page.dart';
import 'package:flutter_blog_post_project/pages/chat_pages/group_chat_page.dart';

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
  late TextEditingController _userSearchController;

  @override
  void initState() {
    super.initState();
    _userSearchController = TextEditingController();
  }

  @override
  void dispose() {
    _userSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text('Message Users'),
        elevation: 4,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'create_group_chat') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateGroupChatPage(),
                  ),
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'create_group_chat',
                child: Row(
                  children: [
                    Icon(Icons.add_circle_outline,
                        color: Theme.of(context).colorScheme.secondary),
                    const SizedBox(width: 10.0),
                    Text(
                      'Create Group Chat',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary),
                    ),
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
          Container(
            margin: const EdgeInsets.symmetric(vertical: 7, horizontal: 16),
            child: MyTextField(
              controller: _userSearchController,
              hintText: 'Search',
              icon: Icons.search,
              obscureText: false,
              borderSideColor: Theme.of(context).colorScheme.secondary,
              focusedBorderColor: Theme.of(context).colorScheme.tertiary,
              hintTextColor: Theme.of(context).colorScheme.tertiary,
              iconColor: Theme.of(context).colorScheme.tertiary,
              cursorColor: Theme.of(context).colorScheme.tertiary,
              onChanged: (_) => setState(() {}),
              suffixIcon: IconButton(
                icon: Icon(
                  Icons.clear,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
                onPressed: () {
                  _userSearchController.clear();
                  setState(() {});
                },
              ),
            ),
          ),
          Expanded(
            child: _buildUserList(),
          ),
          TextButton.icon(
            onPressed: () => showModalBottomSheet(
              context: context,
              builder: (context) => _buildGroupChatList(),
            ),
            icon: Icon(
              Icons.arrow_drop_up,
              color: Theme.of(context).colorScheme.secondary,
            ),
            label: Text(
              'Group Chats',
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            style: TextButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary),
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
          tileColor: Colors.transparent,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: CircleAvatar(
            radius: 30,
            backgroundColor: Theme.of(context).colorScheme.tertiary,
            child: CircleAvatar(
              radius: 25,
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
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

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
              tileColor: Colors.transparent,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: CircleAvatar(
                radius: 30,
                backgroundColor: Theme.of(context).colorScheme.tertiary,
                child: CircleAvatar(
                  radius: 25,
                  backgroundImage: data["group_image"].isNotEmpty &&
                          data["group_image"] != ""
                      ? NetworkImage(data["group_image"])
                      : const AssetImage('images/no_user_image.png')
                          as ImageProvider<Object>?,
                ),
              ),
              title: Text(
                groupChat.roomTitle,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              trailing: Icon(
                Icons.groups_outlined,
                color: Theme.of(context).colorScheme.secondary,
                size: 30,
              ),
              subtitle: StreamBuilder<String?>(
                stream: getAdminNameStream(groupChat.groupAdminId),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    String? adminName = snapshot.data;
                    return Text(
                        "Created by $adminName on ${formatTimestamp(groupChat.createdAt)}");
                  } else if (snapshot.hasError) {
                    return const Text("Error fetching admin name");
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GroupChatPage(
                      groupChat: groupChat,
                    ),
                  ),
                );
              },
            ),
          )
        : const SizedBox.shrink();
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

        var filteredDocs = snapshot.data!.docs.where((doc) {
          String username = doc["username"].toString().toLowerCase();
          String searchQuery = _userSearchController.text.toLowerCase();
          return username.contains(searchQuery);
        }).toList();

        return ListView.builder(
          itemCount: filteredDocs.length,
          itemBuilder: (context, index) {
            return _buildUserListItem(filteredDocs[index]);
          },
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

        var filteredDocs = snapshot.data!.docs.where((doc) {
          String roomTitle = doc["room_title"].toString().toLowerCase();
          String searchQuery = _userSearchController.text.toLowerCase();
          return roomTitle.contains(searchQuery);
        }).toList();

        return Container(
          color: Theme.of(context).colorScheme.background,
          child: ListView.builder(
            itemCount: filteredDocs.length,
            itemBuilder: (context, index) {
              return _buildGroupChatItem(filteredDocs[index]);
            },
          ),
        );
      },
    );
  }

  Stream<String?> getAdminNameStream(String adminId) {
    try {
      return FirebaseFirestore.instance
          .collection('Users')
          .doc(adminId)
          .snapshots()
          .map((snapshot) {
        if (snapshot.exists) {
          Map<String, dynamic> userData = snapshot.data()!;
          return userData['username']
              as String?; // Assuming 'name' field stores the admin name
        } else {
          return null; // Admin with the provided ID not found
        }
      });
    } catch (error) {
      print("Error getting admin data: $error");
      return Stream.value(null);
    }
  }
}
