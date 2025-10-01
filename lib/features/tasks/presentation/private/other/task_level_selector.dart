import 'dart:math';

import 'package:flutter/material.dart';
import 'package:vedem/core/style/app_colors.dart';
import 'package:vedem/core/style/app_style.dart';
import 'package:vedem/core/style/app_text_styles.dart';

class TaskLevelSelector extends StatelessWidget {
  final List<IconData> icons;
  final List<String> labels;
  final List<Color> colors;
  final Function(int) onSelected;
  final int? selectedLevel;
  final double targetWidth;
  final bool rotate;

  const TaskLevelSelector({
    super.key,
    required this.icons,
    required this.labels,
    required this.colors,
    required this.onSelected,
    required this.selectedLevel,
    required this.targetWidth,
    this.rotate = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double spacing = 4.0;
        double singleActiveWidth =
            (constraints.maxWidth - (icons.length - 1) * spacing - 1) /
            (icons.length + 1);
        double singleInactiveWidth =
            (constraints.maxWidth - (icons.length - 1) * spacing - 1) /
            icons.length;

        double _getWidth(int i, int? selected) {
          if (selected == null) return singleInactiveWidth;
          if (selected == i) return 2 * singleActiveWidth;
          return singleActiveWidth;
        }

        return Row(
          spacing: spacing,
          children: [
            for (int i = 0; i < icons.length; i++)
              AnimatedContainer(
                duration: Duration(milliseconds: 200),
                curve: Curves.easeOut,
                height: 60.0,
                width: _getWidth(i, selectedLevel),
                child: SizedBox(
                  child: TextButton(
                    onPressed: () => onSelected(i),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.all(0.0),
                      backgroundColor: AppColors.darkBackgroundColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.circular(
                          AppStyle.roundedCorners,
                        ),
                        side: BorderSide(
                          color: selectedLevel == i ? colors[i] : Colors.black,
                          width: 1.5,
                        ),
                      ),
                      overlayColor: colors[i],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Transform.rotate(
                          angle: rotate ? pi / 2 : 0.0,
                          child: SizedBox(
                            width: 24.0,
                            height: 24.0,
                            child: Icon(
                              icons[i],
                              size: 24.0,
                              color: selectedLevel == i
                                  ? colors[i]
                                  : (selectedLevel == null
                                        ? AppColors.primaryLightTextColor
                                        : AppColors.secondaryLightTextColor),
                            ),
                          ),
                        ),
                        if (i == selectedLevel) ...[
                          Text(
                            labels[i],
                            overflow: TextOverflow.clip,
                            maxLines: 1,
                            style: AppTextStyles.content.copyWith(
                              color: selectedLevel == i
                                  ? colors[i]
                                  : (selectedLevel == null
                                        ? AppColors.primaryLightTextColor
                                        : AppColors.secondaryLightTextColor),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
