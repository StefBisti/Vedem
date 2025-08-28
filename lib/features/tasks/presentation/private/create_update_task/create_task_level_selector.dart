import 'package:flutter/material.dart';
import 'package:vedem/core/style/app_colors.dart';
import 'package:vedem/core/style/app_style.dart';
import 'package:vedem/core/style/app_text_styles.dart';

class CreateTaskLevelSelector extends StatelessWidget {
  final List<IconData> icons;
  final List<String> labels;
  final List<Color> colors;
  final Function(int) onSelected;
  final int selectedLevel;

  const CreateTaskLevelSelector({
    super.key,
    required this.icons,
    required this.labels,
    required this.colors,
    required this.onSelected,
    required this.selectedLevel,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Row(
        spacing: 8.0,
        children: [
          for (int i = 0; i < icons.length; i++)
            Expanded(
              child: TextButton(
                onPressed: () => onSelected(i),
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.darkBackgroundColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(
                      AppStyle.roundedCorners,
                    ),
                    side: BorderSide(
                      color: selectedLevel == i ? colors[i] : Colors.black,
                      width: 1.0,
                    ),
                  ),
                  overlayColor: colors[i],
                  padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 8.0),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icons[i],
                      color: selectedLevel == i
                          ? colors[i]
                          : (selectedLevel == -1
                                ? AppColors.primaryLightTextColor
                                : AppColors.secondaryLightTextColor),
                    ),
                    SizedBox(height: 4.0),
                    Text(
                      labels[i],
                      style: AppTextStyles.content.copyWith(
                        color: selectedLevel == i
                            ? colors[i]
                            : (selectedLevel == -1
                                  ? AppColors.primaryLightTextColor
                                  : AppColors.secondaryLightTextColor),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
