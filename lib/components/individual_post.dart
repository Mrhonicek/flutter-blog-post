import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blog_post_project/components/edit_blog_post.dart';
import 'package:flutter_blog_post_project/components/functions.dart';
import 'package:flutter_blog_post_project/components/like_button.dart';
import 'package:flutter_blog_post_project/components/other_user_profile_page.dart';
import 'package:flutter_blog_post_project/pages/comments_page.dart';
import 'package:flutter_blog_post_project/pages/profile_page.dart';

class IndividualPost extends StatefulWidget {
  final String authorId;
  final String blogId;
  final String email;
  final String bio;
  final String username;
  final String postTitle;
  final String postContent;
  final Timestamp createdAt;
  final String postImage;
  final String userImage;
  final List<String> likes;
  final User currentUser;

  const IndividualPost({
    super.key,
    required this.authorId,
    required this.blogId,
    required this.email,
    required this.bio,
    required this.username,
    required this.postTitle,
    required this.postContent,
    required this.createdAt,
    required this.postImage,
    required this.userImage,
    required this.likes,
    required this.currentUser,
  });

  @override
  State<IndividualPost> createState() => _IndividualPostState();
}

class _IndividualPostState extends State<IndividualPost> {
  bool isLiked = false;
  List<String> likes = [];

  @override
  void initState() {
    // TODO: implement initState
    isLiked = widget.likes.contains(widget.currentUser.uid);
    likes = widget.likes;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.tertiary.withOpacity(0.4),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2), // changes the shadow position
          ),
        ],
      ),
      margin: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                CircleAvatar(
                  radius:
                      22, // Change this radius for the width of the circular border
                  backgroundColor: Theme.of(context).colorScheme.tertiary,
                  child: CircleAvatar(
                    radius:
                        20, // This radius is the radius of the picture in the circle avatar itself.
                    backgroundImage:
                        widget.userImage.isNotEmpty && widget.userImage != ""
                            ? NetworkImage(widget.userImage)
                            : const AssetImage('images/no_user_image.png')
                                as ImageProvider<Object>?,
                  ),
                ),
                const SizedBox(width: 5),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        InkWell(
                          onTap: () {
                            if (widget.currentUser.email == widget.email) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProfilePage(
                                    currentUser: widget.currentUser,
                                  ),
                                ),
                              );
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OtherUserProfilePage(
                                    currentUser: widget.currentUser,
                                    otherUserData: {
                                      'author_id': widget.authorId,
                                      'user_image': widget.userImage,
                                      'email': widget.email,
                                      'username': widget.username,
                                      'bio': widget.bio,
                                    },
                                  ),
                                ),
                              );
                            }
                          },
                          child: Text(
                            widget.username,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.tertiary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Icon(
                          Icons.person,
                          size: 15,
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                        const SizedBox(width: 10),
                      ],
                    ),
                    Text(
                      formatTimestamp(widget.createdAt),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  widget.postTitle,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  widget.postContent,
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          SizedBox(
            child: Image.network(
              widget.postImage,
              height: 300,
              width: double.infinity,
              fit: BoxFit.fill,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  'images/no-image.png',
                  height: 300,
                  width: double.infinity,
                  fit: BoxFit.fitHeight,
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                children: [
                  LikeButton(
                    isLiked: isLiked,
                    onTap: () {
                      setState(() {
                        isLiked = !isLiked;
                      });
                      _updateLikes(widget.blogId, isLiked);
                    },
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: () {
                      setState(() {
                        isLiked = !isLiked;
                      });
                      _updateLikes(widget.blogId, isLiked);
                    },
                    child: Text(
                      '${likes.length} ${likes.length == 1 ? 'Like' : 'Likes'}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.comment),
                    color: Theme.of(context).colorScheme.secondary,
                    onPressed: () {
                      goToPage(
                        context,
                        CommentsPage(
                          blogId: widget.blogId,
                          postImage: widget.postImage,
                          username: widget.username,
                          createdAt: widget.createdAt,
                          currentUser: widget.currentUser,
                        ),
                      );
                    },
                  ),
                  StreamBuilder<int>(
                    stream: getCommentCountStream(widget.blogId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        int commentCount = snapshot.data ?? 0;
                        return InkWell(
                          onTap: () {
                            goToPage(
                              context,
                              CommentsPage(
                                blogId: widget.blogId,
                                postImage: widget.postImage,
                                username: widget.username,
                                createdAt: widget.createdAt,
                                currentUser: widget.currentUser,
                              ),
                            );
                          },
                          child: Text(
                            '$commentCount ${commentCount == 1 ? 'Comment' : 'Comments'}',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
              if (widget.currentUser.uid == widget.authorId)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      color: Theme.of(context).colorScheme.secondary,
                      onPressed: () {
                        _showUpdateDialog(context);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      color: Theme.of(context).colorScheme.secondary,
                      onPressed: () {
                        showAlertDialogDelete(context);
                      },
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Stream<int> getCommentCountStream(String blogId) {
    return FirebaseFirestore.instance
        .collection('Blogs')
        .doc(blogId)
        .collection("Comments")
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  void _updateLikes(String blogId, bool isLiked) async {
    DocumentReference blogPostRef =
        FirebaseFirestore.instance.collection('Blogs').doc(blogId);

    await blogPostRef.get().then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        if (isLiked) {
          blogPostRef.update({
            'likes': FieldValue.arrayUnion([widget.currentUser.uid]),
          });
        } else {
          blogPostRef.update({
            'likes': FieldValue.arrayRemove([widget.currentUser.uid]),
          });
        }
      } else {}
    });

    await FirebaseFirestore.instance
        .collection('Blogs')
        .doc(blogId)
        .get()
        .then((doc) {
      if (doc.exists) {
        setState(() {
          likes = (doc.data() as Map<String, dynamic>)['likes'].cast<String>();
        });
      }
    });
  }

  void deletePost(BuildContext context) {
    if (widget.currentUser.uid == widget.authorId) {
      FirebaseFirestore.instance
          .collection('Blogs')
          .doc(widget.blogId)
          .delete();

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.primary,
            title: Text(
              'Success',
              style: TextStyle(
                color: Theme.of(context).colorScheme.tertiary,
              ),
            ),
            content: Text(
              'Blog post successfully deleted!',
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  'OK',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                ),
              ),
            ],
          );
        },
      );
    } else {
      // print('You are not authorized to delete this post');
    }
  }

  showAlertDialogDelete(BuildContext context) {
    Widget cancelButton = TextButton(
      child: Text(
        "Cancel",
        style: TextStyle(
          color: Theme.of(context).colorScheme.tertiary,
        ),
      ),
      onPressed: () {
        Navigator.pop(context);
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
        deletePost(context);
      },
    );

    AlertDialog alert = AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.primary,
      title: Text(
        "Delete Blog",
        style: TextStyle(
          color: Theme.of(context).colorScheme.tertiary,
        ),
      ),
      content: Text(
        "Are you sure you want to delete this post?",
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

  void _showUpdateDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditBlogPost(
          userId: widget.authorId,
          blogId: widget.blogId,
          postTitle: widget.postTitle,
          postContent: widget.postContent,
          postImage: widget.postImage,
        );
      },
    );
  }
}
