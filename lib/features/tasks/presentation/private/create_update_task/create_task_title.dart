import 'package:flutter/material.dart';
import 'package:vedem/core/style/app_colors.dart';
import 'package:vedem/core/style/app_text_styles.dart';

class CreateTaskTitle extends StatelessWidget {
  const CreateTaskTitle({
    super.key,
    required this.icon,
    required this.text,
    this.iconSize = 20.0,
    this.hidden = false,
  });

  final String text;
  final IconData? icon;
  final double iconSize;
  final bool hidden;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (icon != null)
          Icon(
            icon!,
            color: !hidden
                ? AppColors.primaryLightTextColor
                : AppColors.secondaryLightTextColor,
            size: iconSize,
          ),
        if (icon != null) SizedBox(width: 8.0),
        Text(
          text,
          style: AppTextStyles.content.copyWith(
            color: !hidden
                ? AppColors.primaryLightTextColor
                : AppColors.secondaryLightTextColor,
          ),
        ),
      ],
    );
  }
}
