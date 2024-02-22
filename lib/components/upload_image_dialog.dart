import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blog_post_project/components/functions.dart';
import 'package:flutter_blog_post_project/models/photo.dart';

class UploadImageDialog extends StatefulWidget {
  final String userId;

  const UploadImageDialog({
    super.key,
    required this.userId,
  });

  @override
  State<UploadImageDialog> createState() => _UploadImageDialogState();
}

class _UploadImageDialogState extends State<UploadImageDialog> {
  PlatformFile? pickedFile;
  UploadTask? uploadTask;
  String urlFile = "";

  Future<void> selectFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return;

    setState(() {
      pickedFile = result.files.first;
    });
  }

  Widget imgExist() => Image.file(
        File(pickedFile!.path!),
        width: double.infinity,
        height: 250,
        fit: BoxFit.cover,
      );

  Widget imgNotExist() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Image.asset(
            'images/no-image.png',
            fit: BoxFit.cover,
          ),
        ],
      ),
    );
  }

  Future updateUserImageAtDatabase(urlDownload, context, userId) async {
    final docUser = FirebaseFirestore.instance.collection("Users").doc(userId);

    await docUser.update({
      'user_image': urlDownload,
    }).then((value) {
      showAlert(context, "Success", "Image Update Success!");
    });

    setState(() {
      pickedFile = null;
    });
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

      // Update the database with the download URL and add a new blog post
      // updateDatabase(urlDownload, context);
      updateUserImageAtDatabase(urlDownload, context, widget.userId);

      setState(() {
        // Reset the state if needed
        uploadTask = null;
        Navigator.pop(context);
      });
    } catch (error) {
      // Handle errors during file upload
      print('Error uploading file: $error');
      // You might want to show an error message to the user

      showAlert(
        context,
        "Error",
        "Failed to upload the file. Please try again.",
      );
      // and handle the error accordingly.
      Navigator.pop(context);
    }
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
        "Question",
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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Theme.of(context).colorScheme.primary,
      child: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Profile Picture',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.secondary,
                // Adjust other text style properties as needed
              ),
            ),
            Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(width: 2, color: Colors.grey),
              ),
              child: Center(
                child: SizedBox(
                  height: 300,
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
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
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
                    // No need to call setState here
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
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    ),
                    elevation: MaterialStateProperty.all(
                        5), // Adjust the elevation as needed
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  onPressed: () {
                    if (pickedFile != null) {
                      showAlertDialogUpload(context);
                    } else {
                      showAlert(context, "Error", "Please select a photo!");
                    }
                  },
                  child: Text(
                    'Submit',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      // Adjust text style as needed
                    ),
                  ),
                ),
              ],
            ),
            // Add more buttons or UI elements as needed
          ],
        ),
      ),
    );
  }
}
