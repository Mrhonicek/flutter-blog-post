import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blog_post_project/components/functions.dart';
import 'package:flutter_blog_post_project/components/long_textfield.dart';
import 'package:flutter_blog_post_project/components/textfield.dart';
import 'package:flutter_blog_post_project/models/photo.dart';

class AddBlogPost extends StatefulWidget {
  final String userId;

  const AddBlogPost({
    super.key,
    required this.userId,
  });

  @override
  _AddBlogPostState createState() => _AddBlogPostState();
}

class _AddBlogPostState extends State<AddBlogPost> {
  TextEditingController contentController = TextEditingController();
  TextEditingController titleController = TextEditingController();

  PlatformFile? pickedFile;
  UploadTask? uploadTask;
  String urlFile = "";

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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Theme.of(context).colorScheme.primary,
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Write New Blog',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.secondary,
                  // Adjust other text style properties as needed
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
                        ? imgExist() // Call your function to display Image.file
                        : imgNotExist(), // Call your function to display Image.asset
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
                      elevation: MaterialStateProperty.all(
                          5), // Adjust the elevation as needed
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
                        // Adjust text style as needed
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
                      if (titleController.text.isEmpty ||
                          contentController.text.isEmpty) {
                        showAlert(
                            context, "Error", "Please fill in the textfields");
                      } else if (pickedFile != null) {
                        showAlertDialogUpload(context);
                      } else {
                        showAlert(context, "Error", "Please select a photo!");
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

  Widget imgNotExist() {
    return ListView(
      shrinkWrap: true,
      children: [
        SizedBox(
          height: 250,
          child: Image.asset(
            'images/no_post_image.png',
            width: double.infinity,
            fit: BoxFit.fill,
          ),
        ),
      ],
    );
  }

  showLoaderDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      content: Row(
        children: [
          const CircularProgressIndicator(),
          Container(
            margin: const EdgeInsets.only(left: 7),
            child: const Text("Uploading..."),
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
    final blogId = FirebaseFirestore.instance.collection("Blogs").doc().id;
    final firestoreInstance = FirebaseFirestore.instance;

    final DateTime now = DateTime.now();
    final Timestamp timestamp = Timestamp.fromDate(now);

    await firestoreInstance.collection('Blogs').doc(blogId).set({
      'blog_id': blogId,
      'author_id': widget.userId,
      'content': contentController.text,
      'created_at': timestamp,
      'post_image': imageUrl,
      'title': titleController.text,
      'likes': [],
    }).then((value) => {
          showAlert(context, "Success", "Blog Post Added!"),
        });
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
          color: Theme.of(context).colorScheme.tertiary,
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

  showAlertDialogUpload(BuildContext context) {
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
        uploadFile(context);
      },
    );

    AlertDialog alert = AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.primary,
      title: Text(
        "Add New Blog",
        style: TextStyle(
          color: Theme.of(context).colorScheme.tertiary,
        ),
      ),
      content: Text(
        "Are you sure you want to upload this post?",
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
