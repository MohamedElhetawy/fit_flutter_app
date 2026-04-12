import 'package:flutter/material.dart';
import 'package:fitx/theme/button_theme.dart';
import 'package:fitx/theme/input_decoration_theme.dart';

import '../constants.dart';
import 'checkbox_themedata.dart';
import 'theme_data.dart';

class AppTheme {
  /// Premium dark theme inspired by the reference design.
  static ThemeData darkTheme(BuildContext context) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: plusJakartaFont,
      primarySwatch: primaryMaterialColor,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: bgColor,

      // ── Color Scheme ────────────────────────────────
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        onPrimary: Color(0xFF1A1A00),
        primaryContainer: Color(0xFF3A3A00),
        secondary: primaryColor,
        onSecondary: Color(0xFF1A1A00),
        surface: surfaceColor,
        onSurface: textPrimary,
        surfaceContainerHighest: surfaceColorLight,
        error: errorColor,
        onError: Colors.white,
        outline: surfaceBorder,
        outlineVariant: Color(0xFF1E1E26),
      ),

      // ── Card ────────────────────────────────────────
      cardColor: surfaceColor,
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          side: const BorderSide(color: surfaceBorder, width: 1),
        ),
      ),

      // ── Icons ───────────────────────────────────────
      iconTheme: const IconThemeData(color: textSecondary, size: 22),

      // ── Typography ──────────────────────────────────
      textTheme: const TextTheme(
        // Display — for hero numbers (weight, big stats)
        displayLarge: TextStyle(
          fontFamily: grandisExtendedFont,
          fontSize: 48,
          fontWeight: FontWeight.w900,
          color: textPrimary,
          height: 1.1,
          letterSpacing: -1.5,
        ),
        displayMedium: TextStyle(
          fontFamily: grandisExtendedFont,
          fontSize: 36,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          height: 1.1,
          letterSpacing: -0.5,
        ),
        displaySmall: TextStyle(
          fontFamily: grandisExtendedFont,
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          height: 1.2,
        ),
        // Headlines
        headlineLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: -0.3,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        // Titles
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleSmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textSecondary,
        ),
        // Body
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: textPrimary,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textSecondary,
          height: 1.5,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: textTertiary,
          height: 1.4,
        ),
        // Labels
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: 0.1,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textSecondary,
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: textTertiary,
          letterSpacing: 0.5,
        ),
      ),

      // ── Buttons ─────────────────────────────────────
      elevatedButtonTheme: elevatedButtonThemeData,
      textButtonTheme: textButtonThemeData,
      outlinedButtonTheme: outlinedButtonTheme(borderColor: surfaceBorder),

      // ── Inputs ──────────────────────────────────────
      inputDecorationTheme: darkInputDecorationTheme,
      checkboxTheme: checkboxThemeData,

      // ── AppBar ──────────────────────────────────────
      appBarTheme: appBarDarkTheme,

      // ── Scrollbar ───────────────────────────────────
      scrollbarTheme: scrollbarThemeData,
      dataTableTheme: dataTableDarkThemeData,

      // ── Bottom Nav ──────────────────────────────────
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        selectedItemColor: primaryColor,
        unselectedItemColor: textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w400,
        ),
      ),

      // ── Divider ─────────────────────────────────────
      dividerColor: surfaceBorder,
      dividerTheme: const DividerThemeData(
        color: surfaceBorder,
        thickness: 0.5,
        space: 0,
      ),

      // ── SnackBar ────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceColorLight,
        contentTextStyle: const TextStyle(
          color: textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSm),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // ── Dialog ──────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
        ),
        titleTextStyle: const TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),

      // ── Chip ────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: surfaceColor,
        selectedColor: primaryColor,
        disabledColor: surfaceColor,
        labelStyle: const TextStyle(
          color: textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        secondaryLabelStyle: const TextStyle(
          color: Color(0xFF1A1A00),
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        side: const BorderSide(color: surfaceBorder),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusFull),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),

      // ── System UI ───────────────────────────────────
      // Make status bar blend with bg
    );
  }

  /// Light theme kept as fallback but not used by default.
  static ThemeData lightTheme(BuildContext context) {
    return ThemeData(
      brightness: Brightness.light,
      fontFamily: plusJakartaFont,
      primarySwatch: primaryMaterialColor,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: Colors.white,
      iconTheme: const IconThemeData(color: blackColor),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: blackColor40),
      ),
      elevatedButtonTheme: elevatedButtonThemeData,
      textButtonTheme: textButtonThemeData,
      outlinedButtonTheme: outlinedButtonTheme(),
      inputDecorationTheme: lightInputDecorationTheme,
      checkboxTheme: checkboxThemeData.copyWith(
        side: const BorderSide(color: blackColor40),
      ),
      appBarTheme: appBarLightTheme,
      scrollbarTheme: scrollbarThemeData,
      dataTableTheme: dataTableLightThemeData,
    );
  }

  // ═════════════════════════════════════════════════════════════
  //  UTILITY FUNCTIONS FOR MODERN EFFECTS
  // ═════════════════════════════════════════════════════════════

  /// Glassmorphism container — frosted glass effect with backdrop blur
  static Widget buildGlassmorphicContainer({
    required Widget child,
    Color backgroundColor = const Color(0xFF141418),
    double opacity = 0.15,
    double borderOpacity = 0.1,
    BorderRadius? borderRadius,
    EdgeInsets padding = const EdgeInsets.all(16),
  }) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor.withValues(alpha: opacity),
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: borderOpacity),
          width: 1.5,
        ),
      ),
      child: child,
    );
  }

  /// Premium gradient background
  static LinearGradient buildPremiumGradient({
    Alignment begin = Alignment.topLeft,
    Alignment end = Alignment.bottomRight,
  }) {
    return LinearGradient(
      begin: begin,
      end: end,
      colors: [
        primaryColor.withValues(alpha: 0.08),
        primaryColor.withValues(alpha: 0.02),
      ],
    );
  }

  /// Radial gradient for background ambient effects
  static RadialGradient buildRadialGradient({
    required Color color,
    double maxOpacity = 0.1,
    double radius = 0.5,
  }) {
    return RadialGradient(
      radius: radius,
      colors: [
        color.withValues(alpha: maxOpacity),
        Colors.transparent,
      ],
    );
  }
}
