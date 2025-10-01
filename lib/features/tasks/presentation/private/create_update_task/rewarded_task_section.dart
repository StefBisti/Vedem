import 'package:flutter/material.dart';
import 'package:vedem/core/style/app_colors.dart';
import 'package:vedem/core/style/app_text_styles.dart';
import 'package:vedem/core/utils/time_utils.dart';
import 'package:vedem/features/tasks/presentation/private/other/task_level_selector.dart';
import 'package:vedem/features/tasks/presentation/private/other/task_stepper.dart';

class RewardedTaskSection extends StatelessWidget {
  final bool isRewardedTask;
  final Function() onSwitched;
  final int? effort;
  final int? importance;
  final int? time;
  final int? diamonds;
  final Function(int) onEffortChanged;
  final Function(int) onImportanceChanged;
  final Function(int) onTimeChanged;

  const RewardedTaskSection({
    super.key,
    required this.isRewardedTask,
    required this.onSwitched,
    required this.effort,
    required this.importance,
    required this.time,
    required this.diamonds,
    required this.onEffortChanged,
    required this.onImportanceChanged,
    required this.onTimeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          height: 40.0, // 24.0 content + 16.0 spacing
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
                        value: isRewardedTask,
                        onChanged: (v) {},
                      ),
                    ),
                  ),
                ),
                IgnorePointer(
                  child: Text(
                    'Rewarded task',
                    style: AppTextStyles.content.copyWith(
                      color: AppColors.primaryLightTextColor,
                      fontWeight: isRewardedTask
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        AnimatedSize(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
          child: !isRewardedTask
              ? SizedBox(width: double.infinity, height: 0.0)
              : Padding(
                  padding: EdgeInsetsGeometry.only(left: 0.0), // 48.0
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // REWARDED TASK - EFFORT
                      const SizedBox(height: 16.0),
                      Row(
                        spacing: 8.0,
                        children: [
                          SizedBox(
                            height: 24.0,
                            width: 40.0,
                            child: Icon(
                              Icons.whatshot_rounded,
                              size: 20.0,
                              color: AppColors.primaryLightTextColor,
                            ),
                          ),
                          IgnorePointer(
                            child: Text(
                              'Effort required',
                              style: AppTextStyles.content.copyWith(
                                color: AppColors.primaryLightTextColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8.0),
                      TaskLevelSelector(
                        colors: [
                          Colors.green,
                          Colors.lightGreen,
                          Colors.amber,
                          Colors.orange,
                          Colors.red,
                        ],
                        labels: ['None', 'Light', 'Medium', 'Hard', 'Brutal'],
                        icons: [
                          Icons.battery_0_bar_rounded,
                          Icons.battery_2_bar_rounded,
                          Icons.battery_3_bar_rounded,
                          Icons.battery_5_bar_rounded,
                          Icons.battery_full_rounded,
                        ],
                        selectedLevel: effort,
                        onSelected: onEffortChanged,
                        targetWidth: 80.0,
                        rotate: true,
                      ),

                      // REWARDED TASK - IMPORTANCE
                      const SizedBox(height: 16.0),
                      Row(
                        spacing: 8.0,
                        children: [
                          SizedBox(
                            height: 24.0,
                            width: 40.0,
                            child: Icon(
                              Icons.error_rounded,
                              size: 20.0,
                              color: AppColors.primaryLightTextColor,
                            ),
                          ),
                          IgnorePointer(
                            child: Text(
                              'Task importance',
                              style: AppTextStyles.content.copyWith(
                                color: AppColors.primaryLightTextColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8.0),
                      TaskLevelSelector(
                        colors: [
                          Colors.cyan,
                          Colors.blue,
                          Colors.amber,
                          Colors.orange,
                          Colors.red,
                        ],
                        labels: ['None', 'Minor', 'Normal', 'Major', 'Urgent'],
                        icons: [
                          Icons.star_border_rounded,
                          Icons.star_half_rounded,
                          Icons.star_half_rounded,
                          Icons.star_rounded,
                          Icons.star_rounded,
                        ],
                        selectedLevel: importance,
                        onSelected: onImportanceChanged,
                        targetWidth: 80.0,
                      ),

                      // REWARDED TASK - TIME
                      const SizedBox(height: 16.0),
                      Row(
                        spacing: 8.0,
                        children: [
                          SizedBox(
                            height: 24.0,
                            width: 40.0,
                            child: Icon(
                              Icons.timer_outlined,
                              size: 20.0,
                              color: AppColors.primaryLightTextColor,
                            ),
                          ),
                          IgnorePointer(
                            child: Text(
                              'Time required',
                              style: AppTextStyles.content.copyWith(
                                color: AppColors.primaryLightTextColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8.0),
                      TaskStepper(
                        enabled: true,
                        display: (m) => TimeUtils.minutesToString(m),
                        onChanged: onTimeChanged,
                        min: 0,
                        start: time ?? 0,
                        max: 480,
                        steppers: [
                          0,
                          3,
                          5,
                          6,
                          6,
                          for (int i = 5; i < 10; i++) 10,
                          for (int i = 10; i < 20; i++) 13,
                          100000,
                        ],
                      ),

                      // REWARDED TASKS - RESULTS
                      const SizedBox(height: 8.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'You will get ${diamonds ?? 0} ',
                            style: AppTextStyles.content.copyWith(
                              color: AppColors.primaryLightTextColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Icon(
                            Icons.diamond_rounded,
                            color: AppColors.primaryLightTextColor,
                            size: 16.0,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}
