import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppFonts {
  // Heading 1: Krub / Bold / 22px
  static TextStyle get heading1 => GoogleFonts.krub(
        fontWeight: FontWeight.w700,
        fontSize: 22,
        height: 1.2,
      );

  // Heading 2: Rubik / SemiBold / 20px
  static TextStyle get heading2 => GoogleFonts.rubik(
        fontWeight: FontWeight.w600,
        fontSize: 20,
        height: 1.2,
      );

  // Heading 3: Rubik / Medium / 16px
  static TextStyle get heading3 => GoogleFonts.rubik(
        fontWeight: FontWeight.w500,
        fontSize: 16,
        height: 1.2,
      );

  // Body 1: Rubik / Regular / 12px
  static TextStyle get body1 => GoogleFonts.rubik(
        fontWeight: FontWeight.w400,
        fontSize: 12,
        height: 1.4,
      );
}
