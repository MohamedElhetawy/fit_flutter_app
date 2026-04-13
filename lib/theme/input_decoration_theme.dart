import 'package:flutter/material.dart';

import '../constants.dart';

const InputDecorationTheme lightInputDecorationTheme = InputDecorationTheme(
  fillColor: lightGreyColor,
  filled: true,
  hintStyle: TextStyle(color: greyColor),
  border: outlineInputBorder,
  enabledBorder: outlineInputBorder,
  focusedBorder: focusedOutlineInputBorder,
  errorBorder: errorOutlineInputBorder,
);

const InputDecorationTheme darkInputDecorationTheme = InputDecorationTheme(
  fillColor: surfaceColorLight,
  filled: true,
  hintStyle: TextStyle(color: textTertiary, fontSize: 14),
  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
  border: outlineInputBorder,
  enabledBorder: darkEnabledBorder,
  focusedBorder: focusedOutlineInputBorder,
  errorBorder: errorOutlineInputBorder,
  focusedErrorBorder: errorOutlineInputBorder,
);

const OutlineInputBorder outlineInputBorder = OutlineInputBorder(
  borderRadius: BorderRadius.all(Radius.circular(radiusMd)),
  borderSide: BorderSide(color: Colors.transparent),
);

const OutlineInputBorder darkEnabledBorder = OutlineInputBorder(
  borderRadius: BorderRadius.all(Radius.circular(radiusMd)),
  borderSide: BorderSide(color: surfaceBorder, width: 1),
);

const OutlineInputBorder focusedOutlineInputBorder = OutlineInputBorder(
  borderRadius: BorderRadius.all(Radius.circular(radiusMd)),
  borderSide: BorderSide(color: primaryColor, width: 1.5),
);

const OutlineInputBorder errorOutlineInputBorder = OutlineInputBorder(
  borderRadius: BorderRadius.all(Radius.circular(radiusMd)),
  borderSide: BorderSide(color: errorColor, width: 1.5),
);

OutlineInputBorder secodaryOutlineInputBorder(BuildContext context) {
  return OutlineInputBorder(
    borderRadius: const BorderRadius.all(Radius.circular(radiusMd)),
    borderSide: BorderSide(
      color: Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.15),
    ),
  );
}
