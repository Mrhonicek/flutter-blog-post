import 'package:flutter/material.dart';

ThemeData defaultTheme = ThemeData(
  brightness: Brightness.light,

  colorScheme: const ColorScheme.light(
    background:
        Color.fromARGB(255, 150, 255, 231), // Chetwode Blue (PANTONE 2124 C)
    primary: Color(0xFF00C9A7), // Chetwode Blue (PANTONE 2715 C)
    secondary: Color.fromARGB(255, 255, 255, 255), // Danube (PANTONE 659 C)
    tertiary: Color.fromARGB(255, 36, 99, 87), // Viking (PANTONE 3242 C)
  ),

  // Add more colors as needed
  // tertiary: Color(0xFF73cfd9), // Viking (PANTONE 3242 C)
  // quaternary: Color(0xFF7ed9bf), // Bermuda (PANTONE 7471 C)

  scaffoldBackgroundColor:
      const Color(0xFF1a1a1a), // Adjust background color for Scaffold
  appBarTheme: const AppBarTheme(
    color: Color(0xFF333333), // Adjust app bar color
    elevation: 4.0, // Add elevation/shadow
  ),

  // Add shadows to various components
  cardTheme: const CardTheme(
    elevation: 2.0, // Shadow for cards
  ),

  buttonTheme: ButtonThemeData(
    buttonColor: const Color(0xFF8b89d9), // Button color
    textTheme: ButtonTextTheme.primary,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.0), // Adjust button border radius
    ),
  ),

  // Add more styling as needed
);
