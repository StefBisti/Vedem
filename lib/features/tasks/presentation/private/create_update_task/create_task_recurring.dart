import 'package:flutter/material.dart';
import 'package:vedem/core/style/app_colors.dart';
import 'package:vedem/core/style/app_text_styles.dart';

class CreateTaskRecurring extends StatelessWidget {
  final Function(bool) onChanged;
  final bool hidden;
  final bool isRecurring;

  const CreateTaskRecurring({
    super.key,
    required this.hidden,
    required this.onChanged,
    required this.isRecurring,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onChanged(!isRecurring),
      child: SizedBox(
        width: double.infinity,
        height: 40.0,
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 0.0, right: 8.0),
              child: SizedBox(
                width: 24.0,
                height: 24.0,
                child: Checkbox(
                  value: isRecurring,
                  onChanged: (v) => onChanged(!isRecurring),
                  activeColor: AppColors.primaryLightTextColor,
                  checkColor: AppColors.primaryDarkTextColor,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(4.0),
                  ),
                ),
              ),
            ),
            Text(
              'Recurring',
              style: AppTextStyles.content.copyWith(
                color: !hidden || isRecurring
                    ? AppColors.primaryLightTextColor
                    : AppColors.secondaryLightTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
