
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Colors
const Color kPrimaryColor = Color(0xFFeebd2b);
const Color kEspressoColor = Color(0xFF1B180D);
const Color kIvoryColor = Color(0xFFFCFBF8);

// Additional shared colors used throughout the app
const Color kBackgroundLight = Color(0xFFFDFCFB);
const Color kCharcoalColor = Color(0xFF2D2A26);
const Color kMutedColor = Color(0xFF8C857E);
const Color kChampagneColor = Color(0xFFC5B38A);
const Color kNeutralGoldColor = Color(0xFFE5D9C3);
const Color kMutedGoldColor = Color(0xFFD4BC9A);
const Color kPrimaryBeige = Color(0xFFD4C5A9);
const Color kWarmGrey50 = Color(0xFFFAF9F8);
const Color kWarmGrey100 = Color(0xFFF3F2F0);
const Color kWarmGrey200 = Color(0xFFE5E3DF);
const Color kWarmGrey600 = Color(0xFF78716C);
const Color kSlate950 = Color(0xFF0F172A);
const Color kAccentGold = Color(0xFFA89078);

// Utility for opacity without using deprecated `withOpacity`
Color opacity(Color color, double amount) => color.withAlpha((amount * 255).round());

// Text Styles
final TextStyle kLabelTextStyle = TextStyle(
  fontSize: 10,
  fontWeight: FontWeight.w500,
  color: opacity(kEspressoColor, 0.6),
  letterSpacing: 2,
);

final TextStyle kInputHintStyle = TextStyle(
  color: opacity(kEspressoColor, 0.1),
  fontSize: 14,
);

final TextStyle kHeaderStyle = GoogleFonts.cormorantGaramond(
  fontStyle: FontStyle.italic,
  fontSize: 44,
  fontWeight: FontWeight.w500,
  color: kEspressoColor,
);

final TextStyle kSubHeaderStyle = TextStyle(
  color: opacity(kEspressoColor, 0.4),
  fontSize: 10,
  fontWeight: FontWeight.w300,
  letterSpacing: 2.0,
);

final TextStyle kButtonTextStyle = const TextStyle(
  fontSize: 12,
  fontWeight: FontWeight.w500,
  letterSpacing: 1.2,
  color: kIvoryColor,
);

final TextStyle kFooterTextStyle = TextStyle(
  color: opacity(kEspressoColor, 0.5),
  fontSize: 12,
  fontWeight: FontWeight.w300,
  letterSpacing: 1.0,
);

final TextStyle kLinkTextStyle = TextStyle(
  color: kEspressoColor,
  fontSize: 12,
  fontWeight: FontWeight.w400,
  decoration: TextDecoration.underline,
);

// Padding / Spacing
const double kHorizontalPadding = 24.0;
const double kVerticalPadding = 32.0;
const double kInputFieldHeight = 54.0;

// Border Radius
const BorderRadius kFullBorderRadius = BorderRadius.all(Radius.circular(9999));
