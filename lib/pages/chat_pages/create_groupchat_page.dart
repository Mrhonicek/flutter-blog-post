import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blog_post_project/chat/chat_service.dart';
import 'package:flutter_blog_post_project/components/button.dart';
import 'package:flutter_blog_post_project/components/snackbar.dart';
import 'package:flutter_blog_post_project/components/textfield.dart';
import 'package:flutter_blog_post_project/models/users.dart';

class CreateGroupChatPage extends StatefulWidget {
  const CreateGroupChatPage({super.key});

  @override
  State<CreateGroupChatPage> createState() => _CreateGroupChatPageState();
}

class _CreateGroupChatPageState extends State<CreateGroupChatPage> {
  final _nameController = TextEditingController();
  final _membersController = TextEditingController();
  final List<Users> _selectedUsers = [];
  List<Users> _fetchedUsers = [];
  List<Users> _filteredUsers = [];

  String currentUserId = "";

  @override
  void initState() {
    super.initState();
    _fetchUsers();
    currentUserId = FirebaseAuth.instance.currentUser!.uid;
    _filteredUsers = _fetchedUsers;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          'Create Group Chat',
          style: TextStyle(
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            MyTextField(
              controller: _nameController,
              hintText: 'Group Name',
              icon: Icons.group,
              obscureText: false,
              borderSideColor: Theme.of(context).colorScheme.secondary,
              focusedBorderColor: Theme.of(context).colorScheme.tertiary,
              hintTextColor: Theme.of(context).colorScheme.tertiary,
              iconColor: Theme.of(context).colorScheme.tertiary,
              cursorColor: Theme.of(context).colorScheme.tertiary,
            ),
            const SizedBox(height: 16.0),
            MyTextField(
              controller: _membersController,
              hintText: 'Add members (search)',
              icon: Icons.person_add,
              obscureText: false,
              borderSideColor: Theme.of(context).colorScheme.secondary,
              focusedBorderColor: Theme.of(context).colorScheme.tertiary,
              hintTextColor: Theme.of(context).colorScheme.tertiary,
              iconColor: Theme.of(context).colorScheme.tertiary,
              cursorColor: Theme.of(context).colorScheme.tertiary,
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
            const SizedBox(height: 24.0),
            _buildSelectedUsersGrid(),
            const SizedBox(height: 24.0),
            _buildUserList(),
            const SizedBox(height: 24.0),
            MyButton(
              onTap: () async {
                final String groupName = _nameController.text.trim();
                final List<String> memberIds = [
                  currentUserId,
                  ..._selectedUsers.map((user) => user.userId).toList()
                ];
                if (groupName.isEmpty) {
                  CustomSnackBar.show(
                    context,
                    'Please enter a group name',
                  );
                  return;
                } else if (memberIds.length == 1 &&
                    memberIds.first == currentUserId) {
                  CustomSnackBar.show(
                    context,
                    'Please select at least 1 group member',
                  );
                  return;
                }
                await ChatService().createGroupChat(groupName, memberIds);
                showSuccessSnackBar('Group chat created successfully!');
                _selectedUsers.clear();
                setState(() {});
              },
              text: "Create Group",
            ),
          ],
        ),
      ),
    );
  }

  // ? to avoid using context during asynchronous gaps
  void showSuccessSnackBar(String message) {
    CustomSnackBar.show(
      context,
      message,
      textColor: Theme.of(context).colorScheme.tertiary,
      backgroundColor: Theme.of(context).colorScheme.primary,
    );
  }

  Widget _buildUserList() {
    if (_fetchedUsers.isEmpty) {
      return const Text('Fetching users...');
    } else if (_filteredUsers.isEmpty) {
      return const Text('No matching users found');
    } else {
      return ListView.separated(
        shrinkWrap: true,
        itemCount: _filteredUsers.length,
        separatorBuilder: (context, index) => const SizedBox(height: 5.0),
        itemBuilder: (context, index) {
          final user = _filteredUsers[index];
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
                } else {
                  _selectedUsers.add(user);
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

  Widget _buildSelectedUsersGrid() {
    if (_selectedUsers.isEmpty) {
      return const Text('No users selected');
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
}
