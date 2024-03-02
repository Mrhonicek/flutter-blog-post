import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blog_post_project/components/add_blog_post.dart';
import 'package:flutter_blog_post_project/components/functions.dart';
import 'package:flutter_blog_post_project/components/individual_post.dart';
import 'package:flutter_blog_post_project/components/sidebar.dart';
import 'package:flutter_blog_post_project/models/blogs.dart';
import 'package:flutter_blog_post_project/models/users.dart';
import 'package:flutter_blog_post_project/pages/chat_pages/user_list_page.dart';
import 'package:flutter_blog_post_project/pages/profile_page.dart';
import 'package:flutter_blog_post_project/pages/theme_list_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  bool _isLoading = false;
  String _errorMessage = '';
  List<Blogs> _blogs = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final blogs = await getBlogFuture(); // Use your existing function

      setState(() {
        _blogs = blogs.docs.map((doc) => Blogs.fromJson(doc.data())).toList();
        _isLoading = false;
      });
    } catch (error) {
      print('Error fetching blogs: $error');

      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load blogs. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      drawer: MySidebar(
        currentUser: currentUser,
        onProfileTap: goToProfilePage,
        onLogoutTap: () => showAlertDialogSignOut(context),
        onUserListTap: goToUserListPage,
        onThemesTap: goToThemesPage,
      ),
      appBar: AppBar(
        title: const Text("Blogs"),
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 4,
      ),
      body: RefreshIndicator(
        backgroundColor: Theme.of(context).colorScheme.primary,
        color: Theme.of(context).colorScheme.secondary,
        onRefresh: _handleRefresh,
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
                future: getBlogFuture(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text('No blog posts available.'),
                    );
                  }

                  return buildBlogListView(snapshot.data!.docs);
                },
              ),
            ),
            GestureDetector(
              onTap: () {
                _showPostDialog(context);
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 21),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context)
                          .colorScheme
                          .tertiary
                          .withOpacity(0.4),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.edit,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Write your blog',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildBlogListView(List<QueryDocumentSnapshot> docs) {
    return ListView.builder(
      itemCount: docs.length,
      itemBuilder: (context, index) {
        final blogData = docs[index].data() as Map<String, dynamic>?;

        if (blogData != null) {
          final blog = Blogs.fromJson(blogData);
          return buildIndividualPost(blog);
        } else {
          return const ListTile(
            title: Text('Invalid Author ID'),
            subtitle: Text('Invalid blog data'),
          );
        }
      },
    );
  }

  Widget buildIndividualPost(Blogs blog) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('Users')
          .doc(blog.authorId)
          .get(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (userSnapshot.hasError) {
          return Text('Error: ${userSnapshot.error}');
        }

        final userData = userSnapshot.data!.data() as Map<String, dynamic>;
        final user = Users.fromJson(userData);

        return IndividualPost(
          blogId: blog.blogId,
          authorId: blog.authorId,
          email: user.email,
          bio: user.bio,
          username: user.username,
          postTitle: blog.title,
          postContent: blog.content,
          postImage: blog.postImage,
          userImage: user.userImage,
          createdAt: blog.createdAt,
          likes: blog.likes,
          currentUser: currentUser,
        );
      },
    );
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getBlogFuture() async {
    return await FirebaseFirestore.instance
        .collection('Blogs')
        .orderBy("created_at", descending: true)
        .get();
  }

  void _showPostDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddBlogPost(userId: currentUser.uid);
      },
    );
  }

  Widget buildAvatar(Blogs blog) {
    if (blog.postImage.isNotEmpty) {
      return CircleAvatar(
        backgroundImage: NetworkImage(blog.postImage),
        radius: 25,
      );
    } else {
      return const CircleAvatar(
        radius: 25,
        child: Icon(Icons.person),
      );
    }
  }

  void signOut(BuildContext context) {
    Navigator.pop(context);
    FirebaseAuth.instance.signOut();
  }

  showAlertDialogSignOut(BuildContext context) {
    Widget cancelButton = TextButton(
      child: Text(
        "Cancel",
        style: TextStyle(
          color: Theme.of(context).colorScheme.tertiary,
        ),
      ),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    Widget continueButton = TextButton(
      child: Text(
        "Continue",
        style: TextStyle(
          color: Theme.of(context).colorScheme.tertiary,
        ),
      ),
      onPressed: () {
        Navigator.of(context).pop();
        signOut(context);
      },
    );

    AlertDialog alert = AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.primary,
      title: Text(
        "Logout",
        style: TextStyle(
          color: Theme.of(context).colorScheme.tertiary,
        ),
      ),
      content: Text(
        "Are you sure you want to logout?",
        style: TextStyle(
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void goToProfilePage() {
    Navigator.pop(context);
    goToPage(
      context,
      ProfilePage(
        currentUser: currentUser,
      ),
    );
  }

  void goToUserListPage() {
    Navigator.pop(context);
    goToPage(
      context,
      UserListPage(
        currentUser: currentUser,
      ),
    );
  }

  // TODO: might add in the future
  void goToThemesPage() {
    Navigator.pop(context);
    goToPage(
      context,
      const ThemesListPage(),
    );
  }
}
