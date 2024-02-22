import 'package:flutter/material.dart';

class ProfileTextBox extends StatelessWidget {
  final String text;
  final String sectionName;
  final void Function()? onPressed;

  const ProfileTextBox({
    Key? key,
    required this.text,
    required this.sectionName,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4, // Add elevation to the card
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      color: Theme.of(context).colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  sectionName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                ),
                if (onPressed != null)
                  IconButton(
                    onPressed: onPressed,
                    icon: Icon(
                      Icons.edit_document,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
              ],
            ),
            const SizedBox(
              height: 8,
            ), // Add spacing between sectionName and text
            Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
