import 'package:flutter/material.dart';
import 'package:vedem/core/style/app_colors.dart';
import 'package:vedem/core/style/app_text_styles.dart';

class DailyTaskSection extends StatelessWidget {
  final bool isDailyTask;
  final Function() onSwitched;

  const DailyTaskSection({
    super.key,
    required this.isDailyTask,
    required this.onSwitched,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          height: 40.0, // 24.0 content heigh + 16.0 spacing
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onSwitched,
            child: Row(
              spacing: 8.0,
              children: [
                SizedBox(
                  height: 24.0,
                  width: 40.0,
                  child: Transform.scale(
                    scale: 0.6,
                    child: IgnorePointer(
                      child: Switch(
                        activeColor: AppColors.darkBackgroundColor,
                        activeTrackColor: AppColors.primaryLightTextColor,
                        inactiveThumbColor: AppColors.primaryLightTextColor,
                        inactiveTrackColor: AppColors.darkBackgroundColor,
                        trackOutlineColor: WidgetStatePropertyAll(
                          AppColors.primaryLightTextColor,
                        ),
                        trackOutlineWidth: WidgetStatePropertyAll(1.5),
                        padding: EdgeInsets.all(0.0),
                        value: isDailyTask,
                        onChanged: (v) {},
                      ),
                    ),
                  ),
                ),
                IgnorePointer(
                  child: Text(
                    'Daily task',
                    style: AppTextStyles.content.copyWith(
                      color: AppColors.primaryLightTextColor,
                      fontWeight: isDailyTask
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
