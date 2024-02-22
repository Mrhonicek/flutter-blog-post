import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blog_post_project/theme/custom_theme.dart';
import 'package:flutter_blog_post_project/theme/default_theme.dart';

class ThemesListPage extends StatefulWidget {
  const ThemesListPage({Key? key}) : super(key: key);

  @override
  _ThemesListPageState createState() => _ThemesListPageState();
}

class _ThemesListPageState extends State<ThemesListPage> {
  String? selectedTheme;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text('List of Themes'),
        elevation: 4,
      ),
      body: Container(),
    );
  }
}
