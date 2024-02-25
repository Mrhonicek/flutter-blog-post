import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blog_post_project/chat/chat_service.dart';
import 'package:flutter_blog_post_project/components/chat_bubble.dart';
import 'package:flutter_blog_post_project/components/functions.dart';
import 'package:flutter_blog_post_project/components/textfield.dart';
import 'package:flutter_blog_post_project/models/users.dart';

class ChatPage extends StatefulWidget {
  final String receiverUserEmail;
  final String receiverUserId;
  final String username;

  const ChatPage({
    super.key,
    required this.receiverUserEmail,
    required this.receiverUserId,
    required this.username,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final ChatService _chatService = ChatService();
  final FocusNode _textFieldFocusNode = FocusNode();
  PlatformFile? _selectedFile;

  late ScrollController _listScrollController;

  bool _isInitialScrollDone = false;

  @override
  void initState() {
    // TODO: implement initState
    _listScrollController = ScrollController();
    _textFieldFocusNode.addListener(() {
      if (_textFieldFocusNode.hasFocus) {
        jumpListToEnd();
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _listScrollController.dispose();
    _messageController.dispose();
    _isInitialScrollDone = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(widget.receiverUserEmail),
        actions: [
          IconButton(
            onPressed: () {
              showAlert("Help", "Tap on your own message to delete.");
            },
            icon: const Icon(
              Icons.question_mark,
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _buildMessageList(),
            ),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageList() {
    return StreamBuilder(
      stream: _chatService.getMessages(
        widget.receiverUserId,
        _firebaseAuth.currentUser!.uid,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text("Error ${snapshot.error}");
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final messages = snapshot.data!.docs;

        if (messages.isEmpty) {
          return Center(
            child: Text(
              "Start a conversation!",
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                letterSpacing: 2,
              ),
            ),
          );
        }

        return ListView.builder(
          controller: _listScrollController,
          itemCount: messages.length,
          itemBuilder: (context, index) {
            return FutureBuilder(
              future: Future.delayed(
                Duration.zero, // microtask to ensure controller is attached
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    !_isInitialScrollDone) {
                  jumpListToEnd();
                  _isInitialScrollDone =
                      true; // Set flag to prevent further calls
                }
                return _buildMessageItem(messages[index]);
              },
            );
          },
        );
      },
    );
  }

  void scrollListToEnd() {
    _listScrollController.animateTo(
      _listScrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 200), // Adjust as needed
      curve: Curves.easeOut,
    );
  }

  void jumpListToEnd() {
    _listScrollController.jumpTo(
      _listScrollController.position.maxScrollExtent,
    );
  }

  Widget _buildMessageItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    bool isCurrentUser = data["sender_id"] == _firebaseAuth.currentUser!.uid;
    DateTime messageTimestamp = data["timestamp"].toDate();

    var alignment = (data["sender_id"] == _firebaseAuth.currentUser!.uid)
        ? Alignment.centerRight
        : Alignment.centerLeft;

    var crossAxisAlignment =
        (data["sender_id"] == _firebaseAuth.currentUser!.uid)
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start;

    var mainAxisAlignment =
        (data["sender_id"] == _firebaseAuth.currentUser!.uid)
            ? MainAxisAlignment.end
            : MainAxisAlignment.start;

    return StreamBuilder<Users?>(
      stream: getUserStream(data["sender_id"]),
      builder: (context, snapshot) {
        Users? user = snapshot.data;

        // Display "You" if the sender is the current user
        String username = isCurrentUser ? "You" : user?.username ?? "";
        String userImage = isCurrentUser
            ? "" // Empty string for the current user
            : user?.userImage ?? ""; // Use the fetched user's image for others

        return Container(
          alignment: alignment,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(
                  // ? 10 minutes = 600 seconds
                  formatTimestampWithTimerDisplayDelay(
                    messageTimestamp,
                    600,
                  ),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.tertiary,
                    fontSize: 12,
                  ),
                ),
                Column(
                  crossAxisAlignment: crossAxisAlignment,
                  mainAxisAlignment: mainAxisAlignment,
                  children: [
                    Text(username),
                    // Access other user properties if needed, e.g., user?.userImage
                    const SizedBox(height: 5),
                    Row(
                      crossAxisAlignment: crossAxisAlignment,
                      mainAxisAlignment: mainAxisAlignment,
                      children: [
                        if (!isCurrentUser)
                          CircleAvatar(
                            radius:
                                22, // Change this radius for the width of the circular border
                            backgroundColor:
                                Theme.of(context).colorScheme.tertiary,
                            child: CircleAvatar(
                              radius:
                                  20, // This radius is the radius of the picture in the circle avatar itself.
                              backgroundImage: userImage.isNotEmpty &&
                                      userImage != ""
                                  ? NetworkImage(userImage)
                                  : const AssetImage('images/no_user_image.png')
                                      as ImageProvider<Object>?,
                            ),
                          ),
                        const SizedBox(
                          width: 5,
                        ),
                        Container(
                          constraints: const BoxConstraints(
                            maxWidth: 290,
                          ),
                          child: InkWell(
                            onTap: () {
                              if (data["sender_id"] ==
                                  _firebaseAuth.currentUser!.uid) {
                                showAlertDialogOnDelete(
                                    context, data["message_id"]);
                              }
                            },
                            child: ChatBubble(
                              message: data["message"],
                              imageUrl: data["image_url"],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Stream<Users?> getUserStream(String userId) {
    try {
      return FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .snapshots()
          .map((snapshot) {
        if (snapshot.exists) {
          Map<String, dynamic> userData =
              snapshot.data() as Map<String, dynamic>;
          return Users.fromJson(userData);
        } else {
          return null; // User with the provided userID not found
        }
      });
    } catch (error) {
      print("Error getting user data: $error");
      return Stream.value(null);
    }
  }

  // ? Example code of fetching just the username
  Stream<String?> getUserNameStream(String userId) {
    try {
      return FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .snapshots()
          .map((snapshot) {
        if (snapshot.exists) {
          Map<String, dynamic> userData =
              snapshot.data() as Map<String, dynamic>;
          Users user = Users.fromJson(userData);
          return user.username;
        } else {
          return null; // User with the provided userID not found
        }
      });
    } catch (error) {
      print("Error getting username: $error");
      return Stream.value(null);
    }
  }

  Widget _buildMessageInput() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.tertiary.withOpacity(0.4),
            spreadRadius: 2,
            blurRadius: 5,
            offset:
                const Offset(0, -1), // Set a negative value for upward shift
          )
        ],
      ),
      padding: const EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (_selectedFile == null)
            Expanded(
              child: MyTextField(
                controller: _messageController,
                focusNode: _textFieldFocusNode,
                hintText: "Enter Message",
                obscureText: false,
                icon: Icons.card_giftcard,
              ),
            ),
          const SizedBox(width: 10),
          Row(
            children: [
              _selectedFileWidget,
              IconButton(
                onPressed: _pickFile,
                icon: const Icon(Icons.attach_file_sharp),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                onPressed: sendMessage,
                icon: const Icon(
                  Icons.send_outlined,
                  size: 40,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget get _selectedFileWidget {
    if (_selectedFile != null) {
      return Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            constraints: const BoxConstraints(maxWidth: 230),
            padding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 3.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.background,
              borderRadius: BorderRadius.circular(5.0),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: true, // Start text at the end
              child: Row(
                children: [
                  const SizedBox(width: 5),
                  Text(
                    _selectedFile!.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(width: 5),
                  IconButton(
                    icon: const Icon(Icons.close),
                    iconSize: 20,
                    onPressed: () => setState(() {
                      _selectedFile = null;
                    }),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    } else {
      return const SizedBox();
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.any,
    );

    if (result != null) {
      final file = result.files.single;
      setState(() {
        _selectedFile = file;
      });
      // Handle the selected file (upload, etc.)
    }
  }

  void sendMessage() async {
    if (_messageController.text.isNotEmpty || _selectedFile != null) {
      // Check if a file is selected
      if (_selectedFile != null) {
        final filePath = _selectedFile!.path;

        if (filePath != null) {
          print(filePath);
          final file = File(filePath);

          try {
            await _chatService.sendMessage(
              widget.receiverUserId,
              _messageController.text,
              file,
            );
            // Clear the selected file and message text after successful upload
            _selectedFile = null;
            _messageController.clear();
          } catch (error) {
            // Handle upload error gracefully, e.g., display an error message
            print('Error uploading image: $error');
          }
        }
      } else {
        // Send text message only
        await _chatService.sendMessage(
          widget.receiverUserId,
          _messageController.text,
          null, // No file to send
        );
        // Clear the message text after successful sending
        _messageController.clear();
      }

      // Scroll to the end of the list regardless of message type
      scrollListToEnd();
    }
  }

  void deleteMessage(String messageId) async {
    await _chatService.deleteMessage(
      _firebaseAuth.currentUser!.uid,
      widget.receiverUserId,
      messageId,
    );
  }

  showAlertDialogOnDelete(BuildContext context, String messageId) {
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
        deleteMessage(messageId);
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
        "Are you sure you want to delete this message?",
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

  void showAlert(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          title,
          style: TextStyle(
            color: Theme.of(context).colorScheme.tertiary,
          ),
        ),
        content: Text(
          message,
          style: TextStyle(
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              "OK",
              style: TextStyle(
                color: Theme.of(context).colorScheme.tertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
