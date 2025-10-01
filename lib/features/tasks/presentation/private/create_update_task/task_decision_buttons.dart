import 'package:flutter/material.dart';
import 'package:vedem/core/style/app_colors.dart';
import 'package:vedem/core/style/app_text_styles.dart';

class TaskDecisionButtons extends StatelessWidget {
  final bool enabled;
  final String decisionButtonText;
  final IconData decisionButtonIcon;
  final Function() onDecisionButtonPressed;
  final Function() onCancelButtonPressed;

  const TaskDecisionButtons({
    super.key,
    required this.enabled,
    required this.decisionButtonText,
    required this.decisionButtonIcon,
    required this.onDecisionButtonPressed,
    required this.onCancelButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextButton.icon(
            onPressed: onCancelButtonPressed,
            label: Text(
              'Cancel',
              style: AppTextStyles.content.copyWith(
                color: AppColors.primaryLightTextColor,
              ),
            ),
            icon: Icon(
              Icons.close_rounded,
              size: 20.0,
              color: AppColors.primaryLightTextColor,
            ),
            style: TextButton.styleFrom(
              overlayColor: AppColors.primaryLightTextColor,
              side: BorderSide(
                color: AppColors.primaryLightTextColor,
                width: 1.5,
              ),
            ),
          ),
        ),
        SizedBox(width: 16.0),
        Expanded(
          child: TextButton.icon(
            onPressed: onDecisionButtonPressed,
            label: Text(
              decisionButtonText,
              style: AppTextStyles.content.copyWith(
                color: AppColors.primaryDarkTextColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            icon: Icon(
              decisionButtonIcon,
              size: 20.0,
              color: AppColors.primaryDarkTextColor,
            ),
            style: TextButton.styleFrom(
              overlayColor: AppColors.primaryDarkTextColor,
              backgroundColor: enabled
                  ? AppColors.lightBackgroundColor
                  : AppColors.secondaryLightTextColor,
            ),
          ),
        ),
      ],
    );
  }
}
