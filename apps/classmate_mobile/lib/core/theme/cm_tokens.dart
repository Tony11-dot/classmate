import 'package:flutter/material.dart';

class CMTokens {
  // Layout
  static const double radiusSm = 12;
  static const double radiusMd = 16;
  static const double radiusLg = 22;

  static const double padXs = 8;
  static const double padSm = 12;
  static const double padMd = 16;
  static const double padLg = 20;
  static const double padXl = 28;

  static const double blurSm = 10;
  static const double blurMd = 18;
  static const double blurLg = 28;

  // Neutrals
  static const Color ink = Color(0xFF0B0F17);
  static const Color paper = Color(0xFFF6F7FB);
  static const Color paper2 = Color(0xFFFFFFFF);

  static const Color night = Color(0xFF0A0D14);
  static const Color night2 = Color(0xFF0E1320);

  // Default accent (swap later via settings)
  static const Color accent = Color(0xFF4F8CFF);
  static const Color accent2 = Color(0xFF7C5CFF);

  static const Color good = Color(0xFF2ECC71);
  static const Color warn = Color(0xFFF39C12);
  static const Color bad = Color(0xFFE74C3C);

  static const List<Color> heroGradientLight = [
    Color(0xFFF7F8FF),
    Color(0xFFF3F6FF),
    Color(0xFFF7F8FB),
  ];

  static const List<Color> heroGradientDark = [
    Color(0xFF0B0F17),
    Color(0xFF0C1020),
    Color(0xFF0A0D14),
  ];
}
