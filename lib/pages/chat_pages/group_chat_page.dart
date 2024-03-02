import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blog_post_project/chat/chat_functions.dart';
import 'package:flutter_blog_post_project/chat/chat_service.dart';
import 'package:flutter_blog_post_project/components/chat_bubble.dart';
import 'package:flutter_blog_post_project/components/functions.dart';
import 'package:flutter_blog_post_project/components/textfield.dart';
import 'package:flutter_blog_post_project/components/upload_image_dialog.dart';
import 'package:flutter_blog_post_project/models/groupchat.dart';
import 'package:flutter_blog_post_project/models/users.dart';
import 'package:flutter_blog_post_project/pages/chat_pages/manage_group_members_page.dart';
import 'package:flutter_blog_post_project/pages/chat_pages/group_members_page.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'package:flutter_blog_post_project/notifications/callLocalNotifications.dart';
import 'package:flutter_blog_post_project/notifications/notify.dart';

class GroupChatPage extends StatefulWidget {
  final GroupChat groupChat;

  const GroupChatPage({super.key, required this.groupChat});

  @override
  State<GroupChatPage> createState() => _GroupChatPageState();
}

class _GroupChatPageState extends State<GroupChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final ChatService _chatService = ChatService();
  final FocusNode _textFieldFocusNode = FocusNode();
  PlatformFile? _selectedFile;
  final FlutterTts _flutterTts = FlutterTts();

  late ScrollController _listScrollController;

  DateTime? _latestMessageTimestamp;

  bool _isInitialScrollDone = false;

  @override
  void initState() {
    // TODO: implement initState
    _listScrollController = ScrollController();
    _textFieldFocusNode.addListener(() {
      if (_textFieldFocusNode.hasFocus) {
        // jumpListToEnd(_listScrollController);
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
    final roomTitle = widget.groupChat.roomTitle;
    final memberIds = widget.groupChat.memberIds;
    final groupId = widget.groupChat.groupId;
    final usersFuture = getUsersFromIds(memberIds);

    usersFuture.then((users) {
      for (final user in users) {
        print(user.username);
      }
    });

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(roomTitle),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              // Handle selection
              switch (value) {
                case 'change_group_pic':
                  _showUpdateDialog(context);
                  break;
                case 'manage_members':
                  if (_firebaseAuth.currentUser!.uid ==
                      widget.groupChat.groupAdminId) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ManageGroupMembersPage(groupChat: widget.groupChat),
                      ),
                    );
                  }
                  break;
                case 'view_members':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GroupMembersPage(
                          groupChat: widget.groupChat,
                          currentUser: _firebaseAuth.currentUser!),
                    ),
                  );
                  break;
                case 'help':
                  showAlert(context, "Help",
                      "Tap a message to read the message for you. \n \nLong press on your own message to delete.");
                  break;
                case 'delete_group_chat':
                  showAlertDialogOnDelete(
                    context,
                    groupId,
                    "We understand this might be a big decision. Deleting a group chat means losing all its messages and history. Are you ready to proceed?",
                    (id) => deleteGroupChat(groupId),
                  );
                  break;
                default:
                // Handle unexpected value
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'change_group_pic',
                child: Row(
                  children: [
                    Icon(Icons.image,
                        color: Theme.of(context).colorScheme.secondary),
                    const SizedBox(width: 10.0),
                    Text(
                      'Change Group Pic',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary),
                    ),
                  ],
                ),
              ),
              if (_firebaseAuth.currentUser!.uid ==
                  widget.groupChat.groupAdminId)
                PopupMenuItem(
                  value: 'manage_members',
                  child: Row(
                    children: [
                      Icon(Icons.person_add,
                          color: Theme.of(context).colorScheme.secondary),
                      const SizedBox(width: 10.0),
                      Text(
                        'Manage Members',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary),
                      ),
                    ],
                  ),
                ),
              PopupMenuItem(
                value: 'view_members',
                child: Row(
                  children: [
                    Icon(Icons.list,
                        color: Theme.of(context).colorScheme.secondary),
                    const SizedBox(width: 10.0),
                    Text(
                      'View Members',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary),
                    ),
                  ],
                ),
              ),
              if (_firebaseAuth.currentUser!.uid ==
                  widget.groupChat.groupAdminId)
                PopupMenuItem(
                  value: 'delete_group_chat',
                  child: Row(
                    children: [
                      Icon(Icons.delete_forever_outlined,
                          color: Theme.of(context).colorScheme.secondary),
                      const SizedBox(width: 10.0),
                      Text(
                        'Delete Group Chat',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary),
                      ),
                    ],
                  ),
                ),
              PopupMenuItem(
                value: 'help',
                child: Row(
                  children: [
                    Icon(Icons.help_outline,
                        color: Theme.of(context).colorScheme.secondary),
                    const SizedBox(width: 10.0),
                    Text(
                      'Help',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary),
                    ),
                  ],
                ),
              ),
            ],
            color: Theme.of(context).colorScheme.primary,
            shadowColor: Theme.of(context).colorScheme.tertiary,
          ),
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

  Future<List<Users>> getUsersFromIds(List<String> memberIds) async {
    final usersCollection = FirebaseFirestore.instance.collection('Users');
    final userFutures = memberIds
        .map((memberId) => usersCollection.doc(memberId).get())
        .toList();

    final userDocs = await Future.wait(userFutures);
    final users = userDocs
        .where((doc) => doc.exists)
        .map((doc) => Users.fromJson(doc.data()!))
        .toList();

    return users;
  }

  Widget _buildMessageList() {
    return StreamBuilder(
      stream: _chatService.receiveGroupMessages(
        widget.groupChat.groupId,
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
        if (messages.isNotEmpty) {
          // Update the latest message timestamp
          _latestMessageTimestamp = messages.last["timestamp"].toDate();
        }

        if (messages.isEmpty) {
          return Center(
            child: Text(
              "Start a conversation!",
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
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
                Duration.zero,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    !_isInitialScrollDone) {
                  jumpListToEnd(_listScrollController);
                  _isInitialScrollDone = true;
                }
                return _buildMessageItem(messages[index]);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildMessageItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    bool isCurrentUser = data["sender_id"] == _firebaseAuth.currentUser!.uid;
    DateTime messageTimestamp = data["timestamp"].toDate();
    bool isLatestMessage = messageTimestamp == _latestMessageTimestamp;

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

        String username = isCurrentUser ? "You" : user?.username ?? "";
        String userImage = isCurrentUser ? "" : user?.userImage ?? "";

        if (!isCurrentUser && isLatestMessage) {
          // callLocalNotification(username, data["message"], data["image_url"]);

          String message = data["message"] ?? "";
          String imageUrl = data["image_url"] ?? "";
          String notificationBody =
              imageUrl.isNotEmpty ? "Sent a photo" : message;

          LocalNotification.showBigTextNotification(
            title: username,
            body: notificationBody,
            fln: flutterLocalNotificationsPlugin,
          );
        }

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
                    const SizedBox(height: 5),
                    Row(
                      crossAxisAlignment: crossAxisAlignment,
                      mainAxisAlignment: mainAxisAlignment,
                      children: [
                        if (!isCurrentUser)
                          CircleAvatar(
                            radius: 22,
                            backgroundColor:
                                Theme.of(context).colorScheme.tertiary,
                            child: CircleAvatar(
                              radius: 20,
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
                            onLongPress: () {
                              if (data["sender_id"] ==
                                  _firebaseAuth.currentUser!.uid) {
                                showAlertDialogOnDelete(
                                  context,
                                  data["message_id"],
                                  "Are you sure you want to delete this message?",
                                  (id) =>
                                      deleteGroupMessage(data["message_id"]),
                                );
                              }
                            },
                            onTap: () {
                              if (data["message"] != null &&
                                  data["image_url"] == null) {
                                _flutterTts.speak(data["message"]);
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

  void callLocalNotification(
      String channelTitle, String channelDescription, String? imageUrl) {
    // Check if the message is an image
    if (imageUrl != null) {
      channelDescription = "Sent a photo";
    }

    LocalNotification.showBigTextNotification(
      title: channelTitle,
      body: channelDescription,
      fln: flutterLocalNotificationsPlugin,
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
          return null;
        }
      });
    } catch (error) {
      print("Error getting user data: $error");
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
            offset: const Offset(0, -1),
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
                icon: const Icon(
                  Icons.image_outlined,
                  size: 30,
                ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                onPressed: sendGroupMessage,
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

  void sendGroupMessage() async {
    if (_messageController.text.isNotEmpty || _selectedFile != null) {
      // Check if a file is selected
      if (_selectedFile != null) {
        final filePath = _selectedFile!.path;

        if (filePath != null) {
          print(filePath);
          final file = File(filePath);

          try {
            await _chatService.sendGroupMessage(
              widget.groupChat.groupId,
              _messageController.text,
              file,
            );
            _selectedFile = null;
            _messageController.clear();
          } catch (error) {
            print('Error uploading image: $error');
          }
        }
      } else {
        // Send text message only
        await _chatService.sendGroupMessage(
          widget.groupChat.groupId,
          _messageController.text,
          null, // No file to send
        );
        // Clear the message text after successful sending
        _messageController.clear();
      }
      // Scroll to the end of the list regardless of message type
      scrollListToEnd(_listScrollController);
    }
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

  void deleteGroupMessage(String messageId) async {
    await _chatService.deleteGroupMessage(
      widget.groupChat.groupId,
      messageId,
    );
  }

  void deleteGroupChat(String groupId) async {
    await _chatService.deleteGroupChat(groupId);
  }

  void showAlertDialogOnDelete(
    BuildContext context,
    String toDeleteId,
    String message,
    Function(String id)
        deleteFunction, // Pass the specific delete function as an argument
  ) {
    Widget cancelButton = TextButton(
      child: Text(
        "Cancel",
        style: TextStyle(
          color: Theme.of(context).colorScheme.tertiary,
        ),
      ),
      onPressed: () => Navigator.pop(context),
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
        deleteFunction(toDeleteId);
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
        message,
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
        return UploadImageDialog(
          uploadId: widget.groupChat.groupId,
          collectionName: "Group_Chat_Rooms",
          documentName: "group_image",
          uploadLabel: "Group Image",
        );
      },
    );
  }
}
