import 'package:flutter/material.dart';
import 'package:vedem/core/style/app_colors.dart';
import 'package:vedem/core/style/app_text_styles.dart';

// Cancel or Create task
class CreateTaskDecisionButtons extends StatelessWidget {
  final Function() onCancel, onAccept;
  final bool createHidden;
  final String createText;
  final IconData createIcon;

  const CreateTaskDecisionButtons({
    super.key,
    required this.createHidden,
    required this.onCancel,
    required this.onAccept,
    required this.createIcon,
    required this.createText,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextButton.icon(
            onPressed: onCancel,
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
              side: BorderSide(
                color: AppColors.primaryLightTextColor,
                width: 1.0,
              ),
            ),
          ),
        ),
        SizedBox(width: 16.0),
        Expanded(
          child: TextButton.icon(
            onPressed: onAccept,
            label: Text(
              createText,
              style: AppTextStyles.content.copyWith(
                color: AppColors.primaryDarkTextColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            icon: Icon(
              createIcon,
              size: 20.0,
              color: AppColors.primaryDarkTextColor,
            ),
            style: TextButton.styleFrom(
              backgroundColor: !createHidden
                  ? AppColors.lightBackgroundColor
                  : AppColors.secondaryLightTextColor,
            ),
          ),
        ),
      ],
    );
  }
}
