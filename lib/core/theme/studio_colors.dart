import 'package:flutter/material.dart';

/// MiniMax-inspired Aria design tokens.
class StudioColors {
  StudioColors._();

  // Brand & accent
  static const Color primary = Color(0xFF0A0A0A);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primarySoft = Color(0xFF181E25);
  static const Color brandCoral = Color(0xFFFF5530);
  static const Color brandMagenta = Color(0xFFEA5EC1);
  static const Color brandBlue = Color(0xFF1456F0);
  static const Color brandBlueDeep = Color(0xFF1D4ED8);
  static const Color brandPurple = Color(0xFFA855F7);
  static const Color brandCyan = Color(0xFF3DAEFF);

  // Surfaces
  static const Color canvas = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF7F8FA);
  static const Color surfaceSoft = Color(0xFFF2F3F5);
  static const Color hairline = Color(0xFFE5E7EB);
  static const Color hairlineSoft = Color(0xFFEAECF0);

  // Text
  static const Color ink = Color(0xFF0A0A0A);
  static const Color inkStrong = Color(0xFF000000);
  static const Color charcoal = Color(0xFF222222);
  static const Color slate = Color(0xFF45515E);
  static const Color steel = Color(0xFF5F5F5F);
  static const Color stone = Color(0xFF8E8E93);
  static const Color muted = Color(0xFFA8AAB2);

  // Semantic
  static const Color successBg = Color(0xFFE8FFEA);
  static const Color successText = Color(0xFF1BA673);
  static const Color error = Color(0xFFD45656);
  static const Color footerBg = Color(0xFF0A0A0A);

  // Glass (light frosted)
  static const Color glassFill = Color(0xCCFFFFFF);
  static const Color glassDock = Color(0xE6FFFFFF);
  static const Color glassPill = Color(0xB3F7F8FA);

  // Back-compat aliases used across the app
  static const Color nearBlack = canvas; // pages moved to light canvas
  static const Color darkSurface = surface;
  static const Color midDark = surfaceSoft;
  static const Color darkCard = canvas;
  static const Color midCard = surface;
  static const Color spotifyGreen = primary; // MiniMax primary CTA = black pill
  static const Color spotifyGreenBorder = primary;
  static const Color white = ink; // former on-dark text → ink on light
  static const Color silver = steel;
  static const Color nearWhite = charcoal;
  static const Color light = canvas;
  static const Color negative = error;
  static const Color warning = Color(0xFFFFA42B);
  static const Color announcement = brandBlue;
  static const Color borderGray = hairline;
  static const Color lightBorder = hairline;
  static const Color separator = hairlineSoft;
}
