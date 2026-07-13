import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'studio_colors.dart';

class StudioTheme {
  StudioTheme._();

  static TextTheme _dm(TextTheme base) => GoogleFonts.dmSansTextTheme(base);

  static ThemeData light() {
    final base = _dm(ThemeData.light().textTheme).apply(
      bodyColor: StudioColors.charcoal,
      displayColor: StudioColors.ink,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: StudioColors.canvas,
      canvasColor: StudioColors.canvas,
      cardColor: StudioColors.canvas,
      primaryColor: StudioColors.primary,
      colorScheme: const ColorScheme.light(
        primary: StudioColors.primary,
        secondary: StudioColors.brandCoral,
        surface: StudioColors.canvas,
        error: StudioColors.error,
        onPrimary: StudioColors.onPrimary,
        onSecondary: StudioColors.onPrimary,
        onSurface: StudioColors.ink,
        onError: StudioColors.onPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: StudioColors.canvas,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: base.titleLarge?.copyWith(
          color: StudioColors.ink,
          fontWeight: FontWeight.w600,
          fontSize: 18,
          letterSpacing: -0.2,
        ),
        iconTheme: const IconThemeData(color: StudioColors.ink),
      ),
      textTheme: base.copyWith(
        headlineMedium: base.headlineMedium?.copyWith(
          color: StudioColors.ink,
          fontWeight: FontWeight.w600,
          fontSize: 32,
          height: 1.25,
          letterSpacing: -0.5,
        ),
        titleLarge: base.titleLarge?.copyWith(
          color: StudioColors.ink,
          fontWeight: FontWeight.w600,
          fontSize: 24,
          height: 1.30,
        ),
        titleMedium: base.titleMedium?.copyWith(
          color: StudioColors.ink,
          fontWeight: FontWeight.w600,
          fontSize: 20,
          height: 1.40,
        ),
        bodyLarge: base.bodyLarge?.copyWith(
          color: StudioColors.charcoal,
          fontWeight: FontWeight.w400,
          fontSize: 16,
          height: 1.50,
        ),
        bodyMedium: base.bodyMedium?.copyWith(
          color: StudioColors.steel,
          fontWeight: FontWeight.w400,
          fontSize: 14,
          height: 1.50,
        ),
        labelLarge: base.labelLarge?.copyWith(
          color: StudioColors.onPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 14,
          height: 1.40,
        ),
        labelSmall: base.labelSmall?.copyWith(
          color: StudioColors.stone,
          fontWeight: FontWeight.w400,
          fontSize: 12,
          height: 1.50,
        ),
      ),
      dividerColor: StudioColors.hairline,
      snackBarTheme: SnackBarThemeData(
        backgroundColor: StudioColors.primary,
        contentTextStyle: base.bodyMedium?.copyWith(color: StudioColors.onPrimary),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        selectedItemColor: StudioColors.ink,
        unselectedItemColor: StudioColors.steel,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: StudioColors.primary,
        inactiveTrackColor: StudioColors.hairline,
        thumbColor: StudioColors.primary,
        overlayColor: StudioColors.primary.withValues(alpha: 0.12),
        trackHeight: 3,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: StudioColors.canvas,
        hintStyle: const TextStyle(color: StudioColors.steel),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: StudioColors.hairline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: StudioColors.hairline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: StudioColors.brandBlueDeep, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: StudioColors.primary,
        foregroundColor: StudioColors.onPrimary,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: StudioColors.canvas,
        selectedColor: StudioColors.primary,
        labelStyle: base.bodySmall?.copyWith(fontWeight: FontWeight.w500),
        secondaryLabelStyle: base.bodySmall?.copyWith(
          color: StudioColors.onPrimary,
          fontWeight: FontWeight.w600,
        ),
        side: const BorderSide(color: StudioColors.hairline),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
    );
  }

  /// Prefer light (MiniMax). Keep dark() as alias for existing call sites.
  static ThemeData dark() => light();
}
