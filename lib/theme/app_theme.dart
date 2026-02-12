import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors
  static const Color creamBackground = Color(0xFFFDFBF7);
  static const Color primaryGreen = Color(0xFF4DB6AC); // Teal-ish green
  static const Color accentYellow = Color(0xFFFFD54F); // Duck yellow
  static const Color brownOutline = Color(0xFF5D4037);
  
  // Priority Colors
  static const Color priorityHigh = Color(0xFFFF7043);
  static const Color priorityMedium = Color(0xFFFFCA28);
  static const Color priorityLow = Color(0xFF66BB6A);

  // Text Styles
  static final TextStyle headingStyle = GoogleFonts.fredoka(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: const Color(0xFF2D3436),
  );

  static final TextStyle subheadingStyle = GoogleFonts.baloo2(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: const Color(0xFF636E72),
  );

  static final TextStyle taskTitleStyle = GoogleFonts.baloo2(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: const Color(0xFF2D3436),
  );
  
  static final TextStyle bodyStyle = GoogleFonts.baloo2(
    fontSize: 14,
    color: const Color(0xFF2D3436),
  );
}
