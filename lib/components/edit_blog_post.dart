import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blog_post_project/components/long_textfield.dart';
import 'package:flutter_blog_post_project/components/textfield.dart';
import 'package:flutter_blog_post_project/models/photo.dart';

class EditBlogPost extends StatefulWidget {
  final String userId;
  final String blogId;
  final String postContent;
  final String postTitle;
  final String postImage;

  const EditBlogPost({
    super.key,
    required this.userId,
    required this.blogId,
    required this.postTitle,
    required this.postContent,
    required this.postImage,
  });

  @override
  _EditBlogPostState createState() => _EditBlogPostState();
}

class _EditBlogPostState extends State<EditBlogPost> {
  TextEditingController contentController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  PlatformFile? pickedFile;
  UploadTask? uploadTask;
  String urlFile = "";
  String imageUrl = "";

  @override
  void initState() {
    // TODO: implement initState
    contentController.text = widget.postContent;
    titleController.text = widget.postTitle;
    imageUrl = widget.postImage;
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Theme.of(context).colorScheme.primary,
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Edit Blog Post',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              const SizedBox(height: 20),
              MyTextField(
                controller: titleController,
                obscureText: false,
                icon: Icons.post_add,
                hintText: 'Enter Title',
              ),
              const SizedBox(height: 10),
              MyLongTextField(
                controller: contentController,
                obscureText: false,
                icon: Icons.post_add,
                hintText: 'Write your blog',
              ),
              Container(
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(width: 2, color: Colors.grey),
                ),
                child: Center(
                  child: SizedBox(
                    height: 250,
                    child: pickedFile != null && pickedFile!.path != null
                        ? imgExist()
                        : imgNotExist(
                            widget.postImage,
                          ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                        Theme.of(context).colorScheme.secondary,
                      ),
                      padding: MaterialStateProperty.all(
                        const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 20),
                      ),
                      elevation: MaterialStateProperty.all(5),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    onPressed: () async {
                      selectFile();
                    },
                    child: Text(
                      'Pick File',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                        Theme.of(context).colorScheme.secondary,
                      ),
                      padding: MaterialStateProperty.all(
                        const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 20),
                      ),
                      elevation: MaterialStateProperty.all(5),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    onPressed: () {
                      bool hasTextChanges =
                          contentController.text != widget.postContent ||
                              titleController.text != widget.postTitle;

                      bool hasImageChanges =
                          pickedFile != null || imageUrl.isNotEmpty;

                      // TODO: update code here..
                      if (!hasTextChanges && !hasImageChanges) {
                        showAlert(
                            context, "Info", "There's nothing to update.");
                        return;
                      }

                      if (titleController.text.isEmpty ||
                          contentController.text.isEmpty) {
                        showAlert(
                            context, "Error", "Please fill in the textfields");
                        return;
                      }

                      if (pickedFile != null) {
                        showAlertDialogUpload(
                            context, () => uploadFile(context));
                      } else {
                        showAlertDialogUpload(
                            context, () => updateDatabase(imageUrl, context));
                      }
                    },
                    child: Text(
                      'Submit',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> selectFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return;

    setState(() {
      pickedFile = result.files.first;
    });
  }

  Widget imgExist() => SizedBox(
        height: 250,
        child: Image.file(
          File(pickedFile!.path!),
          width: double.infinity,
          fit: BoxFit.fill,
        ),
      );

  Widget imgNotExist(String uploadImage) {
    return ListView(
      shrinkWrap: true,
      children: [
        if (uploadImage.isNotEmpty)
          SizedBox(
            height: 250,
            child: Image.network(
              uploadImage,
              fit: BoxFit.fill,
              alignment: Alignment.center,
            ),
          ),
        if (uploadImage.isEmpty)
          SizedBox(
            height: 250,
            child: Image.asset(
              'images/no_post_image.png',
              fit: BoxFit.cover,
            ),
          ),
      ],
    );
  }

  String generateRandomImageName(int length) {
    var r = Random();
    const _chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    return List.generate(length, (index) => _chars[r.nextInt(_chars.length)])
        .join();
  }

  showLoaderDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      content: Row(
        children: [
          const CircularProgressIndicator(),
          Container(
            margin: const EdgeInsets.only(left: 7),
            child: const Text("Updating..."),
          ),
        ],
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future<void> uploadFile(BuildContext context) async {
    showLoaderDialog(context);

    final path = 'images/${generateRandomImageName(5)}-${pickedFile!.name}';
    final file = File(pickedFile!.path!);
    final reference = FirebaseStorage.instance.ref().child(path);

    setState(() {
      uploadTask = reference.putFile(file);
    });

    try {
      final snapshot = await uploadTask!.whenComplete(() => {});
      final urlDownload = await snapshot.ref.getDownloadURL();
      print('Download Link: $urlDownload');

      updateDatabase(urlDownload, context);

      setState(() {
        uploadTask = null;
        Navigator.pop(context);
      });
    } catch (error) {
      print('Error uploading file: $error');

      showAlert(
        context,
        "Error",
        "Failed to upload the file. Please try again.",
      );
      Navigator.pop(context);
    }
  }

  Future<void> updateDatabase(String imageUrl, BuildContext context) async {
    final firestoreInstance = FirebaseFirestore.instance;

    await firestoreInstance.collection('Blogs').doc(widget.blogId).update({
      'content': contentController.text,
      'post_image': imageUrl,
      'title': titleController.text,
    }).then((value) => {
          showAlert(context, "Success", "Blog Post Update Success!"),
        });
    ;
  }

  Future updateUserImageAtDatabase(urlDownload, context) async {
    final docUser =
        FirebaseFirestore.instance.collection("Users").doc(widget.userId);

    await docUser.update({
      'image': urlDownload,
    }).then((value) {
      showAlert(context, "Success", "Image Update Success!");
    });

    setState(() {
      pickedFile = null;
    });
  }

  showAlert(BuildContext context, String title, String msg) {
    Widget continueButton = TextButton(
      onPressed: () {
        Navigator.of(context).pop();
        if (title == "Success") {
          if (urlFile == "") urlFile = "-";
          Navigator.of(context).pop(Photo(image: urlFile));
        }
      },
      child: Text(
        "OK",
        style: TextStyle(
          color: Theme.of(context).colorScheme.tertiary,
        ),
      ),
    );

    AlertDialog alert = AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.primary,
      title: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
      content: Text(
        msg,
        style: TextStyle(
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
      actions: [
        continueButton,
      ],
    );

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  showAlertDialogUpload(BuildContext context, Function()? onPressed) {
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
      onPressed: onPressed,
    );

    AlertDialog alert = AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.primary,
      title: Text(
        "Edit Blog Post",
        style: TextStyle(
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
      content: Text(
        "Are you sure you want to update this post?",
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
}
