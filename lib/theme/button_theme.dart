import 'package:flutter/material.dart';

import '../constants.dart';

ElevatedButtonThemeData elevatedButtonThemeData = ElevatedButtonThemeData(
  style: ElevatedButton.styleFrom(
    padding: const EdgeInsets.symmetric(horizontal: spaceLg, vertical: 14),
    backgroundColor: primaryColor,
    foregroundColor: const Color(0xFF1A1A00),
    minimumSize: const Size(double.infinity, 52),
    elevation: 0,
    textStyle: const TextStyle(
      fontFamily: plusJakartaFont,
      fontSize: 15,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.3,
    ),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(radiusMd)),
    ),
  ),
);

OutlinedButtonThemeData outlinedButtonTheme({
  Color borderColor = surfaceBorder,
}) {
  return OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: spaceLg, vertical: 14),
      minimumSize: const Size(double.infinity, 52),
      side: BorderSide(width: 1.5, color: borderColor),
      foregroundColor: textPrimary,
      textStyle: const TextStyle(
        fontFamily: plusJakartaFont,
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(radiusMd)),
      ),
    ),
  );
}

final textButtonThemeData = TextButtonThemeData(
  style: TextButton.styleFrom(
    foregroundColor: primaryColor,
    textStyle: const TextStyle(
      fontFamily: plusJakartaFont,
      fontSize: 14,
      fontWeight: FontWeight.w600,
    ),
  ),
);
