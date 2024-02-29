import 'package:flutter/material.dart';

ThemeData lightOrangeTheme = ThemeData(
  brightness: Brightness.light, // You can change to Brightness.dark if needed

  colorScheme: const ColorScheme.light(
    background: Color(0xFFffdbb7), // Set your background color
    primary: Color.fromARGB(255, 255, 148, 42), // Set your primary color
    secondary: Color(0xFFffead5), // Set your secondary color
    tertiary: Color.fromARGB(255, 155, 77, 0), // Set your tertiary color
  ),
);
