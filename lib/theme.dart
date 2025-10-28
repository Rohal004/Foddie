import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static final darkGreenTheme = ThemeData(
    scaffoldBackgroundColor: const Color(0xFFF7F8FB),
    primaryColor: const Color(0xFF303F9F), // Indigo
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF303F9F), // Indigo
      secondary: Color(0xFFFFC107), // Amber
    ),
    textTheme: GoogleFonts.poppinsTextTheme(),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF303F9F),
      elevation: 0,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(const Color(0xFF303F9F)),
        foregroundColor: WidgetStateProperty.all(const Color(0xFFFFFFFF)),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    ),
  );
}
