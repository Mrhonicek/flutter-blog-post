import 'package:flutter/material.dart';

ThemeData darkOrangeTheme = ThemeData(
  brightness: Brightness.dark, // You can change to Brightness.dark if needed

  colorScheme: const ColorScheme.dark(
    background: Color.fromARGB(255, 51, 44, 36), // Set your background color
    primary: Color(0xFFFF8F01), // Set your primary color
    secondary: Color.fromARGB(255, 255, 212, 168), //  Set your secondary color
    tertiary: Color.fromARGB(255, 255, 225, 179), // Set your tertiary color
  ),
);
