import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';

// ── Typography ───────────────────────────────────────────────
const grandisExtendedFont = 'Grandis Extended';
const plusJakartaFont = 'Plus Jakarta';

// ══════════════════════════════════════════════════════════════
//  PRIMARY ACCENT — Olive / Lime-Green (from reference design)
// ══════════════════════════════════════════════════════════════
const Color primaryColor = Color(0xFFCDDC39);          // Lime-green
const Color primaryColorDark = Color(0xFFAFB42B);      // Deeper olive
const Color primaryColorLight = Color(0xFFE6EE9C);     // Light lime
const Color primaryColorMuted = Color(0xFF9E9D24);     // Muted olive

const MaterialColor primaryMaterialColor =
    MaterialColor(0xFFCDDC39, <int, Color>{
  50: Color(0xFFF9FBE7),
  100: Color(0xFFF0F4C3),
  200: Color(0xFFE6EE9C),
  300: Color(0xFFDCE775),
  400: Color(0xFFD4E157),
  500: Color(0xFFCDDC39),
  600: Color(0xFFC0CA33),
  700: Color(0xFFAFB42B),
  800: Color(0xFF9E9D24),
  900: Color(0xFF827717),
});

// ══════════════════════════════════════════════════════════════
//  DARK PALETTE — Deep black with subtle warm undertone
// ══════════════════════════════════════════════════════════════
const Color bgColor = Color(0xFF0A0A0C);               // True deep BG
const Color surfaceColor = Color(0xFF141418);           // Card/surface BG
const Color surfaceColorLight = Color(0xFF1C1C22);      // Elevated surface
const Color surfaceBorder = Color(0xFF2A2A32);          // Subtle borders
const Color surfaceHover = Color(0xFF222228);           // Hover states

// Legacy aliases for compatibility
const Color blackColor = bgColor;
const Color blackColor80 = surfaceColor;
const Color blackColor60 = surfaceBorder;
const Color blackColor40 = Color(0xFF6E6E80);           // Text secondary
const Color blackColor20 = Color(0xFFD0D0D2);
const Color blackColor10 = Color(0xFFE8E8E9);
const Color blackColor5 = Color(0xFFF3F3F4);

// ── White palette ────────────────────────────────────────────
const Color whiteColor = Colors.white;
const Color textPrimary = Color(0xFFF5F5F7);            // Apple-white
const Color textSecondary = Color(0xFF6E6E80);           // Muted
const Color textTertiary = Color(0xFF48485A);            // Disabled
const Color whileColor80 = Color(0xFFCCCCCC);
const Color whileColor60 = Color(0xFF999999);
const Color whileColor40 = Color(0xFF666666);
const Color whileColor20 = Color(0xFF333333);
const Color whileColor10 = Color(0xFF191919);
const Color whileColor5 = Color(0xFF0D0D0D);

// ── Semantic colors ──────────────────────────────────────────
const Color greyColor = Color(0xFFB8B5C3);
const Color lightGreyColor = Color(0xFFF8F8F9);
const Color darkGreyColor = Color(0xFF1C1C25);
const Color purpleColor = Color(0xFF7B61FF);
const Color successColor = Color(0xFFCDDC39);            // Matches accent
const Color warningColor = Color(0xFFFFBE21);
const Color errorColor = Color(0xFFEA5B5B);

// ══════════════════════════════════════════════════════════════
//  SPACING SCALE — 4px micro-grid
// ══════════════════════════════════════════════════════════════
const double spaceXs = 4.0;
const double spaceSm = 8.0;
const double spaceMd = 16.0;
const double spaceLg = 24.0;
const double spaceXl = 32.0;
const double spaceXxl = 48.0;

const double defaultPadding = 20.0;    // Primary screen padding
const double defaultBorderRadious = 16.0;

// ── Border radius scale ──────────────────────────────────────
const double radiusXs = 8.0;
const double radiusSm = 12.0;
const double radiusMd = 16.0;
const double radiusLg = 20.0;
const double radiusXl = 28.0;
const double radiusXxl = 36.0;
const double radiusFull = 999.0;

// ── Animation ────────────────────────────────────────────────
const Duration defaultDuration = Duration(milliseconds: 300);
const Duration fastDuration = Duration(milliseconds: 150);
const Duration slowDuration = Duration(milliseconds: 500);
const Curve defaultCurve = Curves.easeOutCubic;

// ── Shadows ──────────────────────────────────────────────────
List<BoxShadow> get accentGlow => [
      BoxShadow(
        color: primaryColor.withAlpha(64),
        blurRadius: 20,
        spreadRadius: 0,
        offset: const Offset(0, 4),
      ),
    ];

List<BoxShadow> get subtleShadow => [
      BoxShadow(
        color: Colors.black.withAlpha(77),
        blurRadius: 16,
        spreadRadius: 0,
        offset: const Offset(0, 4),
      ),
    ];

// ── Validators ───────────────────────────────────────────────
final passwordValidator = MultiValidator([
  RequiredValidator(errorText: 'Password is required'),
  MinLengthValidator(8, errorText: 'password must be at least 8 digits long'),
  PatternValidator(r'(?=.*?[#?!@$%^&*-])',
      errorText: 'passwords must have at least one special character')
]);

final emailValidator = MultiValidator([
  RequiredValidator(errorText: 'Email is required'),
  EmailValidator(errorText: 'Enter a valid email address'),
]);

const pasNotMatchErrorText = 'passwords do not match';
