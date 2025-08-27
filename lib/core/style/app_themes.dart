import 'package:flutter/material.dart';
import 'package:vedem/core/style/app_colors.dart';
import 'package:vedem/core/style/app_style.dart';

class AppThemes {
  static ThemeData theme = ThemeData(
    fontFamily: 'Figtree',
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: AppColors.lightBackgroundColor,
      selectionColor: AppColors.lightBackgroundColor.withAlpha(64),
      selectionHandleColor: AppColors.lightBackgroundColor,
    ),
    checkboxTheme: CheckboxThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(4.0),
      ),
      side: BorderSide(color: AppColors.secondaryDarkTextColor, width: 1.0),
      overlayColor: WidgetStateProperty.all(Colors.transparent),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(AppStyle.roundedCorners),
        ),
        overlayColor: Colors.white,
      ),
    ),
  );
}
