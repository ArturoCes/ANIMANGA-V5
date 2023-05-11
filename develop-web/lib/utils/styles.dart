import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AnimangaStyle {
  // Colors
  static const Color primaryColor = Color.fromARGB(255, 137, 24, 146);
  static const Color secondaryColor = Color.fromARGB(255, 229, 69, 168);
  static const Color tertiaryColor = Color.fromARGB(255, 200, 77, 212);
  static const Color quaternaryColor = Color(0xFF404040);
  static const Color formColor = Color.fromARGB(255, 160, 20, 207);
  static const Color redColor = Color(0xFFF35050);
  static Color greyBoxColor =
      Color.fromARGB(255, 255, 255, 255).withOpacity(0.6);
      static Color greyBoxColor1 =
      Color.fromARGB(255, 174, 173, 173).withOpacity(0.6);
  static const Color whiteColor = Color(0xFFFFFFFF);
  static const Color blackColor = Color(0xFF000000);

  // Margins, Paddings, Card properties
  static const double bodyPadding = 20.0;
  static const double cardElevation = 1.0;
  static const double cardBorderRadius = 15;

  // Font sizes, TextStyles
  static const double textSizeZero = 10.0;
  static const double textSizeOne = 12.0;
  static const double textSizeTwo = 14.0;
  static const double textSizeThree = 18.0;
  static const double textSizeFour = 20.0;
  static const double textSizeFive = 24.0;
  static const double textSizeSix = 64.0;

  static TextStyle get textTitle => GoogleFonts.getFont(
        'Mohave',
        color: AnimangaStyle.whiteColor,
        fontWeight: FontWeight.w600,
        fontSize: 35,
      );

  static TextStyle textCustom(Color c, double fSize) => GoogleFonts.getFont(
        'Mohave',
        color: c,
        fontWeight: FontWeight.w500,
        fontSize: fSize,
      );

  static TextStyle get textPrincipal => GoogleFonts.getFont('Mohave',
      color: AnimangaStyle.whiteColor,
      fontWeight: FontWeight.w500,
      fontSize: AnimangaStyle.textSizeSix,
      height: 1);
}