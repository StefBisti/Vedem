import 'package:flutter/material.dart';
import 'package:vedem/core/style/app_colors.dart';
import 'package:vedem/core/style/app_text_styles.dart';
import 'package:vedem/core/utils/time_utils.dart';
import 'package:vedem/features/tasks/presentation/private/other/task_calendar.dart';
import 'package:vedem/features/tasks/presentation/private/other/task_time_chooser.dart';

class MoreOptionsSection extends StatelessWidget {
  final bool isMoreOptionsActive;
  final bool isDueTimeActive;
  final bool isNotifyTimeActive;
  final int dueTime, notifyTime;
  final String? addToDate;
  final Function() onMoreOptionsSwitched;
  final Function() onDueTimeSwitched;
  final Function() onNotifyTimeSwitched;
  final Function(int) onDueTimeChanged;
  final Function(int) onNotifyTimeChanged;
  final Function(String)? onAddToDateChanged;

  const MoreOptionsSection({
    super.key,
    required this.isMoreOptionsActive,
    required this.isDueTimeActive,
    required this.isNotifyTimeActive,
    required this.onMoreOptionsSwitched,
    required this.onDueTimeSwitched,
    required this.onNotifyTimeSwitched,
    required this.onDueTimeChanged,
    required this.onNotifyTimeChanged,
    required this.onAddToDateChanged,
    required this.dueTime,
    required this.notifyTime,
    required this.addToDate,
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
            onTap: onMoreOptionsSwitched,
            child: Row(
              spacing: 8.0,
              children: [
                SizedBox(
                  height: 24.0,
                  width: 40.0,
                  child: IgnorePointer(
                    child: Icon(
                      isMoreOptionsActive
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      size: 24.0,
                      color: AppColors.primaryLightTextColor,
                    ),
                  ),
                ),
                IgnorePointer(
                  child: Text(
                    isMoreOptionsActive ? 'Fewer options' : 'More options',
                    style: AppTextStyles.content.copyWith(
                      color: AppColors.primaryLightTextColor,
                      fontWeight: isMoreOptionsActive
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
          child: !isMoreOptionsActive
              ? SizedBox(width: double.infinity, height: 0.0)
              : Padding(
                  padding: EdgeInsetsGeometry.only(left: 0.0), // 48.0
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // DUE TIME
                      SizedBox(height: 8.0),
                      SizedBox(
                        width: double.infinity,
                        height: 40.0, // 24.0 + 16.0
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: onDueTimeSwitched,
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
                                      activeColor:
                                          AppColors.darkBackgroundColor,
                                      activeTrackColor:
                                          AppColors.primaryLightTextColor,
                                      inactiveThumbColor:
                                          AppColors.primaryLightTextColor,
                                      inactiveTrackColor:
                                          AppColors.darkBackgroundColor,
                                      trackOutlineColor: WidgetStatePropertyAll(
                                        AppColors.primaryLightTextColor,
                                      ),
                                      trackOutlineWidth: WidgetStatePropertyAll(
                                        1.5,
                                      ),
                                      padding: EdgeInsets.all(0.0),
                                      value: isDueTimeActive,
                                      onChanged: (v) {}, // Do nothing
                                    ),
                                  ),
                                ),
                              ),
                              IgnorePointer(
                                child: Text(
                                  'Due time',
                                  style: AppTextStyles.content.copyWith(
                                    color: AppColors.primaryLightTextColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      TaskTimeChooser(
                        enabled: isDueTimeActive,
                        onChanged: onDueTimeChanged,
                        startTimeInMinutes: dueTime,
                      ),

                      // NOTIFY TIME
                      SizedBox(height: 8.0),
                      SizedBox(
                        width: double.infinity,
                        height: 40.0, // 24.0 + 16.0
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: onNotifyTimeSwitched,
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
                                      activeColor:
                                          AppColors.darkBackgroundColor,
                                      activeTrackColor:
                                          AppColors.primaryLightTextColor,
                                      inactiveThumbColor:
                                          AppColors.primaryLightTextColor,
                                      inactiveTrackColor:
                                          AppColors.darkBackgroundColor,
                                      trackOutlineColor: WidgetStatePropertyAll(
                                        AppColors.primaryLightTextColor,
                                      ),
                                      trackOutlineWidth: WidgetStatePropertyAll(
                                        1.5,
                                      ),
                                      padding: EdgeInsets.all(0.0),
                                      value: isNotifyTimeActive,
                                      onChanged: (v) {}, // Do nothing
                                    ),
                                  ),
                                ),
                              ),
                              IgnorePointer(
                                child: Text(
                                  'Notify time',
                                  style: AppTextStyles.content.copyWith(
                                    color: AppColors.primaryLightTextColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      TaskTimeChooser(
                        enabled: isNotifyTimeActive,
                        onChanged: onNotifyTimeChanged,
                        startTimeInMinutes: notifyTime,
                      ),

                      if (addToDate != null && onAddToDateChanged != null) ...[
                        // CALENDAR
                        SizedBox(height: 8.0),
                        SizedBox(
                          width: double.infinity,
                          height: 40.0, // 24.0 + 16.0
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              onAddToDateChanged!(TimeUtils.thisDayId);
                            },
                            child: Row(
                              spacing: 8.0,
                              children: [
                                SizedBox(
                                  height: 24.0,
                                  width: 40.0,
                                  child: IgnorePointer(
                                    child: Icon(
                                      Icons.calendar_month_rounded,
                                      size: 20.0,
                                      color: AppColors.primaryLightTextColor,
                                    ),
                                  ),
                                ),
                                IgnorePointer(
                                  child: Text(
                                    'Add to date - ${TimeUtils.formatDayId(addToDate!, addYear: true)}',
                                    style: AppTextStyles.content.copyWith(
                                      color: AppColors.primaryLightTextColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 300.0),
                          child: TaskCalendar(
                            selectedDayId: addToDate!,
                            todayDayId: TimeUtils.thisDayId,
                            onNewDaySelected: onAddToDateChanged!,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}
