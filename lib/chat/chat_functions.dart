import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

void scrollListToEnd(ScrollController _listScrollController) {
  _listScrollController.animateTo(
    _listScrollController.position.maxScrollExtent,
    duration: const Duration(milliseconds: 200),
    curve: Curves.easeOut,
  );
}

void jumpListToEnd(ScrollController _listScrollController) {
  _listScrollController.jumpTo(
    _listScrollController.position.maxScrollExtent,
  );
}

// ? END OF SCROLL-CONTROLLERS =========================

void showAlert(BuildContext context, String title, String message) {
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

Widget _buildMessageInput(
  BuildContext context,
  PlatformFile _selectedFile,
  TextEditingController _messageController,
  FocusNode _textFieldFocusNode,
  Widget _selectedFileWidget,
  Function() _pickFile,
  Function() sendMessage,
) {
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
