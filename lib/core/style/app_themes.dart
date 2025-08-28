import 'package:flutter/material.dart';
import 'package:vedem/core/style/app_colors.dart';
import 'package:vedem/core/style/app_style.dart';

class AppThemes {
  static ThemeData lightTheme = ThemeData(
    fontFamily: 'Figtree',
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: AppColors.lightBackgroundColor,
      selectionColor: AppColors.lightBackgroundColor.withAlpha(64),
      selectionHandleColor: AppColors.lightBackgroundColor,
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
