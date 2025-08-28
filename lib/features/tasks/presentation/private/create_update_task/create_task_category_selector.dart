import 'package:flutter/material.dart';
import 'package:vedem/core/style/app_colors.dart';
import 'package:vedem/core/style/app_style.dart';
import 'package:vedem/core/style/app_text_styles.dart';

class CreateTaskCategorySelector extends StatelessWidget {
  const CreateTaskCategorySelector({
    super.key,
    required this.categoriesNames,
    required this.categoriesColors,
    required this.categoriesIcons,
    required this.selectedCategoryIndex,
    required this.onSelected,
  });

  final List<String> categoriesNames;
  final List<Color> categoriesColors;
  final List<IconData> categoriesIcons;
  final int selectedCategoryIndex;
  final Function(int) onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 2.0,
      children: [
        for (int i = 0; i < categoriesNames.length; i++)
          TextButton.icon(
            onPressed: () => onSelected(i),
            label: Text(
              categoriesNames[i],
              style: AppTextStyles.content.copyWith(
                color: selectedCategoryIndex == i
                    ? categoriesColors[i]
                    : (selectedCategoryIndex == -1
                          ? AppColors.primaryLightTextColor
                          : AppColors.secondaryLightTextColor),
              ),
            ),
            icon: Icon(
              categoriesIcons[i],
              color: selectedCategoryIndex == i
                  ? categoriesColors[i]
                  : (selectedCategoryIndex == -1
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
                  color: selectedCategoryIndex == i ? categoriesColors[i] : Colors.black,
                  width: 1.0,
                ),
              ),
              overlayColor: categoriesColors[i],
            ),
          ),
      ],
    );
  }
}
