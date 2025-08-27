import 'package:flutter/material.dart';
import 'package:vedem/core/style/app_colors.dart';
import 'package:vedem/core/style/app_text_styles.dart';

class CreateTaskTitle extends StatelessWidget {
  const CreateTaskTitle({
    super.key,
    required this.icon,
    required this.text,
    this.iconSize = 20.0,
  });

  final String text;
  final IconData? icon;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (icon != null)
          Icon(icon!, color: AppColors.primaryLightTextColor, size: iconSize),
        if (icon != null) SizedBox(width: 8.0),
        Text(
          text,
          style: AppTextStyles.content.copyWith(
            color: AppColors.primaryLightTextColor,
          ),
        ),
      ],
    );
  }
}
