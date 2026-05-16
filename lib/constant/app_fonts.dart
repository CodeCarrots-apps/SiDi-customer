import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppFonts {
  const AppFonts._();

  static TextStyle inter({
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? height,
    double? letterSpacing,
    Color? color,
    TextDecoration? decoration,
    Color? decorationColor,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      height: height,
      letterSpacing: letterSpacing,
      color: color,
    ).copyWith(decoration: decoration, decorationColor: decorationColor);
  }

  static TextStyle cormorantGaramond({
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? height,
    double? letterSpacing,
    Color? color,
    TextDecoration? decoration,
    Color? decorationColor,
  }) {
    return GoogleFonts.cormorantGaramond(
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      height: height,
      letterSpacing: letterSpacing,
      color: color,
    ).copyWith(decoration: decoration, decorationColor: decorationColor);
  }

  static TextStyle playfairDisplay({
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? height,
    double? letterSpacing,
    Color? color,
    TextDecoration? decoration,
    Color? decorationColor,
  }) {
    return GoogleFonts.playfairDisplay(
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      height: height,
      letterSpacing: letterSpacing,
      color: color,
    ).copyWith(decoration: decoration, decorationColor: decorationColor);
  }
}
