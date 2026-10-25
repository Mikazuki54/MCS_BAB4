import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppStyles {
  static final titleFontStyle = GoogleFonts.oswald(
    fontSize: 17,
    color: Colors.white,
    fontWeight: FontWeight.bold,
  );

  static final subTitleFontStyle = GoogleFonts.robotoFlex(
    fontSize: 17,
    color: Colors.white,
    fontWeight: FontWeight.bold,
  );

  static final subTitleFontWIthStrokeStyle = GoogleFonts.robotoMono(
    fontSize: 17,
    color: Colors.white,
    textStyle: TextStyle(
      fontWeight: FontWeight.bold,
      foreground: Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..color = Colors.black,
    ),
  );

  static final universalFontStyle = GoogleFonts.poppins(
    fontSize: 14,
    color: Colors.white,
  );
}