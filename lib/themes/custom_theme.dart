import 'package:flutter/material.dart';

ThemeData customTheme = ThemeData(
  brightness: Brightness.dark, // You can change to Brightness.dark if needed

  colorScheme: const ColorScheme.dark(
    background: Color(0xFF845EC2), // Set your background color
    primary: Color(0xFF4B4453), // Set your primary color
    secondary: Color.fromARGB(255, 191, 179, 204), // Set your secondary color
    tertiary: Color(0xFFFEFEDF), // Set your tertiary color
  ),

  scaffoldBackgroundColor:
      Color(0xFF845EC2), // Adjust background color for Scaffold
  appBarTheme: const AppBarTheme(
    color: Color(0xFF4B4453), // Adjust app bar color
    elevation: 4.0, // Add elevation/shadow
  ),

  cardTheme: const CardTheme(
    elevation: 5.0, // Shadow for cards
  ),

  buttonTheme: ButtonThemeData(
    buttonColor: Color(0xFFB0A8B9), // Button color
    textTheme: ButtonTextTheme.primary,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12.0), // Adjust button border radius
    ),
  ),

  // Add more styling as needed
);
