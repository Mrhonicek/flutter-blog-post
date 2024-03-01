import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blog_post_project/chat/chat_service.dart';
import 'package:flutter_blog_post_project/components/button.dart';
import 'package:flutter_blog_post_project/components/snackbar.dart';
import 'package:flutter_blog_post_project/components/textfield.dart';
import 'package:flutter_blog_post_project/models/groupchat.dart';
import 'package:flutter_blog_post_project/models/users.dart';

class ManageGroupMembersPage extends StatefulWidget {
  final GroupChat groupChat;
  const ManageGroupMembersPage({super.key, required this.groupChat});

  @override
  State<ManageGroupMembersPage> createState() => _ManageGroupMembersPageState();
}

class _ManageGroupMembersPageState extends State<ManageGroupMembersPage> {
  final _membersController = TextEditingController();
  List<Users> _selectedUsers = [];
  List<Users> _fetchedUsers = [];
  List<Users> _filteredUsers = [];

  Set<String> _memberIds = {};

  String currentUserId = '';
  String groupId = '';

  @override
  void initState() {
    super.initState();
    print(widget.groupChat.memberIds);
    _fetchUsers();
    _fetchUsersFromMemberIds();
    currentUserId = FirebaseAuth.instance.currentUser!.uid;
    _filteredUsers = _fetchedUsers;
    _selectedUsers = _fetchedUsers;

    _memberIds = Set.from(widget.groupChat.memberIds);
    groupId = widget.groupChat.groupId;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          'Manage Group Members',
          style: TextStyle(
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Theme.of(context).colorScheme.secondary,
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context)
                              .colorScheme
                              .tertiary
                              .withOpacity(0.3),
                          blurRadius: 5,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: MyTextField(
                      controller: _membersController,
                      hintText: 'Add members (search)',
                      icon: Icons.person_add,
                      obscureText: false,
                      borderSideColor: Theme.of(context).colorScheme.secondary,
                      focusedBorderColor:
                          Theme.of(context).colorScheme.tertiary,
                      hintTextColor: Theme.of(context).colorScheme.tertiary,
                      iconColor: Theme.of(context).colorScheme.tertiary,
                      cursorColor: Theme.of(context).colorScheme.primary,
                      textColor: Theme.of(context).colorScheme.tertiary,
                      onChanged: (String value) {
                        if (value.isEmpty) {
                          setState(() {
                            _filteredUsers = _fetchedUsers;
                          });
                        } else {
                          _filteredUsers = _fetchedUsers
                              .where((user) => user.username
                                  .toLowerCase()
                                  .contains(value.toLowerCase()))
                              .toList();
                          setState(() {});
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  Row(
                    children: [
                      Text(
                        "Current Members",
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Expanded(
                    child: _buildSelectedUsersGrid(),
                  ),
                  const SizedBox(height: 24.0),
                  Row(
                    children: [
                      Text(
                        "User List",
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Expanded(
                    child: _buildUserList(),
                  ),
                  const SizedBox(height: 24.0),
                  MyButton(
                    onTap: () async {
                      final List<String> memberIds = [
                        currentUserId,
                        ..._selectedUsers.map((user) => user.userId).toList()
                      ];
                      await ChatService().updateGroupMembers(
                        groupId,
                        memberIds,
                      );
                      showSuccessSnackBar(
                          'Group members updated successfully!');
                      _selectedUsers.clear();
                      setState(() {});
                    },
                    text: "Update Members",
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _fetchUsers() async {
    try {
      final users = <Users>[];
      final collection = FirebaseFirestore.instance.collection('Users');
      final snapshot = await collection.get();

      for (final doc in snapshot.docs) {
        final user = Users.fromJson(doc.data());

        if (user.userId != currentUserId) {
          users.add(user);
        }
      }
      setState(() {
        _fetchedUsers = users;
      });
    } catch (error) {
      print(error.toString());
    }
  }

  void _fetchUsersFromMemberIds() async {
    final adminUserId = FirebaseAuth.instance.currentUser!.uid;

    for (var userId in widget.groupChat.memberIds) {
      if (userId != adminUserId) {
        try {
          final docSnapshot = await FirebaseFirestore.instance
              .collection('Users')
              .doc(userId)
              .get();
          if (docSnapshot.exists) {
            final user = Users.fromJson(docSnapshot.data()!);
            setState(() {
              _selectedUsers.add(user);
            });
          }
        } catch (error) {
          print("Error fetching user data: $error");
        }
      }
    }
  }

  Widget _buildSelectedUsersGrid() {
    if (_selectedUsers.isEmpty) {
      return Text(
        'No users selected',
        style: TextStyle(
          color: Theme.of(context).colorScheme.tertiary,
        ),
      );
    } else {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 10.0,
          crossAxisSpacing: 5.0,
        ),
        itemCount: _selectedUsers.length,
        itemBuilder: (context, index) {
          final user = _selectedUsers[index];
          return Container(
            padding: const EdgeInsets.all(8.0),
            constraints: const BoxConstraints(
              maxHeight: 20.0,
              maxWidth: 150.0,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    user.username,
                    style: const TextStyle(fontSize: 14.0),
                  ),
                ),
                const SizedBox(
                  width: 8.0,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  color: Theme.of(context).colorScheme.error,
                  iconSize: 18,
                  onPressed: () {
                    setState(() {
                      _selectedUsers.remove(user);
                      _memberIds.remove(user.userId);
                    });
                  },
                ),
              ],
            ),
          );
        },
      );
    }
  }

  Widget _buildUserList() {
    if (_fetchedUsers.isEmpty) {
      return Text(
        'Fetching users...',
        style: TextStyle(
          color: Theme.of(context).colorScheme.tertiary,
        ),
      );
    } else if (_filteredUsers.isEmpty) {
      if (_membersController.text.isNotEmpty) {
        return Text(
          'No matching users found in the search results.',
          style: TextStyle(
            color: Theme.of(context).colorScheme.tertiary,
          ),
        );
      } else {
        return Text(
          'No users added to the group yet.',
          style: TextStyle(
            color: Theme.of(context).colorScheme.tertiary,
          ),
        );
      }
    } else {
      final availableUsers = _filteredUsers
          .where((user) => !_memberIds.contains(user.userId))
          .toList();

      if (availableUsers.isEmpty) {
        return Text(
          'Searched users will appear here.',
          style: TextStyle(
            color: Theme.of(context).colorScheme.tertiary,
          ),
        );
      } else {
        return ListView.separated(
          shrinkWrap: true,
          itemCount: availableUsers.length,
          separatorBuilder: (context, index) => const SizedBox(height: 5.0),
          itemBuilder: (context, index) {
            final user = availableUsers[index];
            return ListTile(
              tileColor: Theme.of(context).colorScheme.primary,
              leading: Icon(
                Icons.person,
                color: Theme.of(context).colorScheme.tertiary,
              ),
              title: Text(user.username),
              onTap: () {
                setState(() {
                  if (_selectedUsers.contains(user)) {
                    _selectedUsers.remove(user);
                    _memberIds.remove(user.userId);
                  } else {
                    _selectedUsers.add(user);
                    _memberIds.add(user.userId);
                  }
                });
              },
              selected: _selectedUsers.contains(user),
              selectedTileColor: Theme.of(context).colorScheme.secondary,
            );
          },
        );
      }
    }
  }

  void showSuccessSnackBar(String message) {
    CustomSnackBar.show(
      context,
      message,
      textColor: Theme.of(context).colorScheme.tertiary,
      backgroundColor: Theme.of(context).colorScheme.primary,
    );
  }
}
