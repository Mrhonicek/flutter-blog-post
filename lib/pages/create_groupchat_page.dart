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
  final List<Users> _selectedUsers = []; // Queue for selected users
  List<Users> _fetchedUsers = []; // List to store fetched users
  List<Users> _filteredUsers = []; // List to store filtered users

  String currentUserId = ""; // the user operating the device

  @override
  void initState() {
    super.initState();
    _fetchUsers(); // Fetch users on page initialization
    currentUserId = FirebaseAuth.instance.currentUser!.uid;
    // Initialize _filteredUsers with fetched users
    _filteredUsers = _fetchedUsers;
  }

  Future<void> _fetchUsers() async {
    try {
      final users = <Users>[]; // Empty list to store fetched users

      final collection = FirebaseFirestore.instance.collection('Users');
      final snapshot = await collection.get();

      for (final doc in snapshot.docs) {
        final user = Users.fromJson(doc.data());
        // Filter out the current user during fetching
        if (user.userId != currentUserId) {
          users.add(user);
        }
      }
      setState(() {
        _fetchedUsers = users; // Update state with filtered users
      });
    } catch (error) {
      // Handle errors here (e.g., print error message)
      print(error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Create Group Chat'),
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
            ),
            const SizedBox(height: 16.0),
            MyTextField(
              controller: _membersController,
              hintText: 'Add members (search)',
              icon: Icons.person_add,
              obscureText: false,
              onChanged: (String value) {
                if (value.isEmpty) {
                  // Clear search and display all users
                  setState(() {
                    _filteredUsers = _fetchedUsers;
                  });
                } else {
                  // Perform filtering based on search text
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
            // Display selected users grid
            _buildSelectedUsersGrid(),

            const SizedBox(height: 24.0),

            // Display filtered users
            _buildUserList(),

            const SizedBox(height: 24.0),
            // Add a button to handle creating the group chat
            MyButton(
              onTap: () async {
                // Get group name and member IDs
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
            // Add background color

            tileColor: Theme.of(context).colorScheme.primary,

            // Add leading icon (adjust size and color based on your icon)
            leading: Icon(
              Icons.person,
              color: Theme.of(context).colorScheme.tertiary,
            ),

            title: Text(user.username),
            onTap: () {
              // Update selected users and UI here
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
              maxHeight: 20.0, // Adjust minimum height for each item
              maxWidth: 150.0, // Adjust maximum width for each item
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
                    style: const TextStyle(fontSize: 14.0), // Adjust font size
                  ),
                ),
                const SizedBox(
                  width: 8.0,
                ), // Add space between text and button
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
