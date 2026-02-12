import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color creamBackground = Color(0xFFF5EFD8);
  static const Color primaryGreen = Color(0xFF1B5E20);
  static const Color accentYellow = Color(0xFFFFD54F);
  static const Color brownOutline = Color(0xFF6D3B1A);
  static const Color priorityHigh = Color(0xFFE57373);
  static const Color priorityMedium = Color(0xFFFFB74D);
  static const Color priorityLow = Color(0xFF81C784);

  static TextStyle get headingStyle => GoogleFonts.fredoka(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: primaryGreen,
  );

  static TextStyle get subheadingStyle => GoogleFonts.baloo2(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: brownOutline,
  );

  static TextStyle get taskTitleStyle => GoogleFonts.baloo2(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: Colors.black87,
  );

  static TextStyle get bodyStyle => GoogleFonts.baloo2(
    fontSize: 14,
    color: Colors.black54,
  );
}
