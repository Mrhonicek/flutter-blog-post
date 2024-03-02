import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blog_post_project/components/sidebar_list_tiles.dart';
import 'package:flutter_blog_post_project/models/users.dart';
import 'package:flutter_blog_post_project/pages/weather_page.dart';

class MySidebar extends StatefulWidget {
  final User currentUser;
  final void Function() onProfileTap;
  final void Function() onLogoutTap;
  final void Function() onUserListTap;
  final void Function() onThemesTap;

  const MySidebar({
    super.key,
    required this.onProfileTap,
    required this.onLogoutTap,
    required this.currentUser,
    required this.onUserListTap,
    required this.onThemesTap,
  });

  @override
  State<MySidebar> createState() => _MySidebarState();
}

class _MySidebarState extends State<MySidebar> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.primary,
      child: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("Users")
            .doc(widget.currentUser.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final userData = snapshot.data!.data() as Map<String, dynamic>;
            final user = Users.fromJson(userData);

            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    const SizedBox(height: 50),
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Theme.of(context).colorScheme.tertiary,
                      child: CircleAvatar(
                        radius: 45,
                        backgroundImage:
                            user.userImage.isNotEmpty && user.userImage != ""
                                ? NetworkImage(user.userImage)
                                : const AssetImage('images/no_user_image.png')
                                    as ImageProvider<Object>?,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      "Welcome back ${user.username}!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 50),
                    SideBarListTile(
                      icon: Icons.home,
                      text: "Home",
                      onTap: () => Navigator.pop(context),
                    ),
                    SideBarListTile(
                      icon: Icons.person,
                      text: "Your Profile",
                      onTap: widget.onProfileTap,
                    ),
                    SideBarListTile(
                      icon: Icons.chat_outlined,
                      text: "Message Users",
                      onTap: widget.onUserListTap,
                    ),
                    SideBarListTile(
                      icon: Icons.cloud,
                      text: "Weather Update",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const WeatherPage()),
                        );
                      },
                    ),
                    // SideBarListTile(
                    //   icon: Icons.broken_image_outlined,
                    //   text: "Themes",
                    //   onTap: widget.onThemesTap,
                    // ),
                  ],
                ),

                // TODO: logout
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: SideBarListTile(
                    icon: Icons.logout,
                    text: "Logout",
                    onTap: widget.onLogoutTap,
                  ),
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
