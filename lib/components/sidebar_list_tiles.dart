import 'package:flutter/material.dart';

class SideBarListTile extends StatelessWidget {
  final IconData icon;
  final String text;
  final void Function() onTap;

  const SideBarListTile({
    super.key,
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: Theme.of(context).colorScheme.secondary,
      ),
      onTap: onTap,
      title: Text(
        text,
        style: TextStyle(
            color: Theme.of(context).colorScheme.secondary, fontSize: 16),
      ),
    );
  }
}
