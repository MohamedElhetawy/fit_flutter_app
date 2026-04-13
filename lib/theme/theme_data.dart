import 'package:flutter/material.dart';

import '../constants.dart';

const AppBarTheme appBarLightTheme = AppBarTheme(
  backgroundColor: Colors.white,
  elevation: 0,
  scrolledUnderElevation: 0,
  iconTheme: IconThemeData(color: blackColor),
  titleTextStyle: TextStyle(
    fontFamily: plusJakartaFont,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: blackColor,
  ),
);

const AppBarTheme appBarDarkTheme = AppBarTheme(
  backgroundColor: Colors.transparent,
  elevation: 0,
  scrolledUnderElevation: 0,
  surfaceTintColor: Colors.transparent,
  iconTheme: IconThemeData(color: textPrimary, size: 22),
  titleTextStyle: TextStyle(
    fontFamily: plusJakartaFont,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    letterSpacing: -0.2,
  ),
  centerTitle: true,
);

ScrollbarThemeData scrollbarThemeData = ScrollbarThemeData(
  trackColor: WidgetStateProperty.all(surfaceBorder),
  thumbColor: WidgetStateProperty.all(primaryColor.withOpacity(0.5)),
  radius: const Radius.circular(radiusFull),
  thickness: WidgetStateProperty.all(4),
);

DataTableThemeData dataTableLightThemeData = DataTableThemeData(
  columnSpacing: 24,
  headingRowColor: WidgetStateProperty.all(Colors.black12),
  decoration: BoxDecoration(
    borderRadius: const BorderRadius.all(Radius.circular(radiusMd)),
    border: Border.all(color: Colors.black12),
  ),
  dataTextStyle: const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: blackColor,
  ),
);

DataTableThemeData dataTableDarkThemeData = DataTableThemeData(
  columnSpacing: 24,
  headingRowColor: WidgetStateProperty.all(surfaceColorLight),
  decoration: BoxDecoration(
    borderRadius: const BorderRadius.all(Radius.circular(radiusMd)),
    border: Border.all(color: surfaceBorder),
  ),
  dataTextStyle: const TextStyle(
    fontWeight: FontWeight.w500,
    color: textPrimary,
    fontSize: 12,
  ),
);
