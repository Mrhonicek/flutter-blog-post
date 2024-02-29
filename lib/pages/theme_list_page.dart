import 'package:flutter/material.dart';

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
