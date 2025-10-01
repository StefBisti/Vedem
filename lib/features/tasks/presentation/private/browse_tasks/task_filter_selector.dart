import 'package:flutter/material.dart';
import 'package:vedem/core/style/app_colors.dart';
import 'package:vedem/core/style/app_style.dart';
import 'package:vedem/core/style/app_text_styles.dart';

class TaskFilterSelector extends StatelessWidget {
  final List<String> labels;
  final List<Color> colors;
  final List<IconData> icons;
  final int selectedIndex;
  final Function(int) onSelected;

  const TaskFilterSelector({
    super.key,
    required this.labels,
    required this.colors,
    required this.icons,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 2.0,
      children: [
        for (int i = 0; i < labels.length; i++)
          TextButton.icon(
            onPressed: () => onSelected(i),
            label: Text(
              labels[i],
              style: AppTextStyles.content.copyWith(
                color: selectedIndex == i
                    ? colors[i]
                    : (selectedIndex == -1
                          ? AppColors.primaryLightTextColor
                          : AppColors.secondaryLightTextColor),
              ),
            ),
            icon: Icon(
              icons[i],
              color: selectedIndex == i
                  ? colors[i]
                  : (selectedIndex == -1
                        ? AppColors.primaryLightTextColor
                        : AppColors.secondaryLightTextColor),
            ),
            style: TextButton.styleFrom(
              backgroundColor: AppColors.darkBackgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadiusGeometry.circular(
                  AppStyle.roundedCorners,
                ),
                side: BorderSide(
                  color: selectedIndex == i
                      ? colors[i]
                      : Colors.black,
                  width: 1.0,
                ),
              ),
              overlayColor: colors[i],
            ),
          ),
      ],
    );
  }
}