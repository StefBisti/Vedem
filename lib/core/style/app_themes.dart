import 'package:flutter/material.dart';
import 'package:vedem/core/style/app_colors.dart';
import 'package:vedem/core/style/app_style.dart';

class AppThemes {
  static ThemeData lightTheme = ThemeData(
    fontFamily: 'Figtree',
    applyElevationOverlayColor: false,
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: AppColors.primaryDarkTextColor,
      selectionColor: AppColors.primaryDarkTextColor.withAlpha(64),
      selectionHandleColor: AppColors.primaryDarkTextColor,
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(AppStyle.roundedCorners),
        ),
      ),
    ),
  );
  static ThemeData darkTheme = ThemeData(
    fontFamily: 'Figtree',
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: AppColors.primaryLightTextColor,
      selectionColor: AppColors.primaryLightTextColor.withAlpha(64),
      selectionHandleColor: AppColors.primaryLightTextColor,
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(AppStyle.roundedCorners),
        ),
      ),
    ),
  );
}
