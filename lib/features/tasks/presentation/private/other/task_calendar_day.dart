import 'package:flutter/material.dart';
import 'package:vedem/core/style/app_colors.dart';
import 'package:vedem/core/style/app_text_styles.dart';

class TaskCalendarDay extends StatelessWidget {
  final int? day;
  final bool isToday;
  final bool isSelected;
  final bool isEnabled;
  final Function() onSelected;

  const TaskCalendarDay({
    super.key,
    required this.day,
    required this.isToday,
    required this.isSelected,
    required this.isEnabled,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: day != null,
      child: GestureDetector(
        onTap: () {
          if (isEnabled) {
            onSelected();
          }
        },
        child: Container(
          margin: EdgeInsets.all(4.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            color: isSelected
                ? isEnabled
                      ? AppColors.primaryLightTextColor
                      : AppColors.secondaryLightTextColor
                : Colors.transparent,
            border: BoxBorder.all(
              color: (isToday && !isSelected)
                  ? AppColors.primaryLightTextColor
                  : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              day.toString(),
              style: AppTextStyles.content.copyWith(
                color: isSelected
                    ? AppColors.primaryDarkTextColor
                    : isEnabled
                    ? AppColors.primaryLightTextColor
                    : AppColors.secondaryLightTextColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
