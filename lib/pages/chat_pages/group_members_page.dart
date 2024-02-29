import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blog_post_project/components/other_user_profile_page.dart';
import 'package:flutter_blog_post_project/models/groupchat.dart';
import 'package:flutter_blog_post_project/models/users.dart';
import 'package:flutter_blog_post_project/pages/profile_page.dart';

class GroupMembersPage extends StatefulWidget {
  final User currentUser;
  final GroupChat groupChat;

  const GroupMembersPage(
      {super.key, required this.groupChat, required this.currentUser});

  @override
  State<GroupMembersPage> createState() => GroupMembersPageState();
}

class GroupMembersPageState extends State<GroupMembersPage> {
  late Stream<List<Users>> userListStream;

  @override
  void initState() {
    super.initState();
    userListStream = _getMembersStream(widget.groupChat.groupId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text("Group Members"),
      ),
      body: StreamBuilder<List<Users>>(
        stream: userListStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text("Error: ${snapshot.error}");
          }
          if (snapshot.hasData) {
            final users = snapshot.data!;
            return _buildMembersList(users);
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildMembersList(List<Users> users) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        final isAdmin = widget.groupChat.groupAdminId == user.userId;
        return ListTile(
          leading: CircleAvatar(
            radius: 22,
            backgroundColor: Theme.of(context).colorScheme.tertiary,
            child: CircleAvatar(
              radius: 20,
              backgroundImage: user.userImage.isNotEmpty && user.userImage != ""
                  ? NetworkImage(user.userImage)
                  : const AssetImage('images/no_user_image.png')
                      as ImageProvider<Object>?,
            ),
          ),
          title: Row(
            children: [
              Flexible(
                child: Text(
                  user.username,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.tertiary),
                ),
              ),
              const SizedBox(width: 4.0),
              if (isAdmin)
                Row(
                  children: [
                    const Icon(
                      Icons.admin_panel_settings_outlined,
                      color: Colors.amber,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      "Admin",
                      style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.tertiary),
                    ),
                  ],
                ),
            ],
          ),
          onTap: () {
            // Navigate based on user comparison
            if (widget.currentUser.email == user.email) {
              // Navigate to own profile
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ProfilePage(currentUser: widget.currentUser),
                ),
              );
            } else {
              // Navigate to other user's profile
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OtherUserProfilePage(
                    currentUser: widget.currentUser,
                    otherUserData: {
                      'author_id': user.userId,
                      'user_image': user.userImage,
                      'email': user.email,
                      'username': user.username,
                      'bio': user.bio,
                    },
                  ),
                ),
              );
            }
          },
        );
      },
    );
  }

  Stream<List<Users>> _getMembersStream(String groupId) {
    return FirebaseFirestore.instance
        .collection('Group_Chat_Rooms')
        .doc(groupId)
        .snapshots()
        .asyncMap((docSnapshot) async {
      if (!docSnapshot.exists) {
        return [];
      }

      final memberIds =
          (docSnapshot.data()!['member_ids'] as List<dynamic>).cast<String>();
      return FirebaseFirestore.instance
          .collection('Users')
          .where(FieldPath.documentId, whereIn: memberIds)
          .get()
          // Use await to resolve the promise before returning
          .then((querySnapshot) => querySnapshot.docs
              .map((doc) => Users.fromJson(doc.data()))
              .toList());
    });
  }
}
