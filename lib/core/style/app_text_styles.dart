import 'package:flutter/widgets.dart';
import 'package:vedem/core/style/app_colors.dart';

class AppTextStyles {
  static const TextStyle heading = TextStyle(
    fontFamily: 'Figtree',
    fontSize: 18.0,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryDarkTextColor,
  );
  static const TextStyle content = TextStyle(
    fontFamily: 'Figtree',
    fontSize: 14.0,
    fontWeight: FontWeight.normal,
    color: AppColors.secondaryDarkTextColor,
  );
}
