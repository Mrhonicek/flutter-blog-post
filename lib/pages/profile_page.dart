import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blog_post_project/components/profile_text_box.dart';
import 'package:flutter_blog_post_project/components/upload_image_dialog.dart';
import 'package:flutter_blog_post_project/models/users.dart';

class ProfilePage extends StatefulWidget {
  final User currentUser;

  const ProfilePage({super.key, required this.currentUser});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final usersCollection = FirebaseFirestore.instance.collection("Users");

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
            .doc(widget.currentUser.uid)
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

                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 120),
                  child: TextButton(
                    onPressed: () {
                      _showUpdateDialog(context);
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.all(4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    ),
                    child: Text(
                      "Upload Profile Picture",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8.0),

                CircleAvatar(
                  radius: 70,
                  backgroundColor: Theme.of(context).colorScheme.tertiary,
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
                  widget.currentUser.email!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.tertiary,
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
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
                  onPressed: () => editField('username'),
                ),
                ProfileTextBox(
                  text: user.bio,
                  sectionName: "Bio",
                  onPressed: () => editField('bio'),
                ),

                // TODO: add this ??
                // const Padding(
                //   padding: EdgeInsets.only(
                //     left: 25,
                //   ),
                //   child: Text(
                //     'User Posts',
                //     style: TextStyle(
                //       color: letterColors,
                //     ),
                //   ),
                // ),
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

  Future<void> editField(String field) async {
    String newValue = '';
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text("Edit $field"),
        content: TextField(
          autofocus: true,
          style: TextStyle(
            color: Theme.of(context).colorScheme.secondary,
          ),
          decoration: InputDecoration(
            hintText: "Enter new $field",
            hintStyle: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.tertiary,
              ),
            ),
          ),
          cursorColor:
              Theme.of(context).colorScheme.tertiary, // Set the cursor color
          onChanged: (value) {
            newValue = value;
          },
        ),
        actions: [
          TextButton(
            child: Text(
              "Cancel",
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          TextButton(
            child: Text(
              "Save Changes",
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop(newValue);
            },
          ),
        ],
      ),
    );

    //update in firestore
    if (newValue.trim().isNotEmpty) {
      await usersCollection.doc(widget.currentUser.uid).update(
        {field: newValue},
      );
    }
  }

  void _showUpdateDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return UploadImageDialog(
          uploadId: widget.currentUser.uid,
          collectionName: "Users",
          documentName: "user_image",
          uploadLabel: "Profile Picture",
        );
      },
    );
  }
}
