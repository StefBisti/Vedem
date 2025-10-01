import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vedem/core/style/app_colors.dart';
import 'package:vedem/core/style/app_text_styles.dart';
import 'package:vedem/features/tasks/presentation/private/other/task_calendar_day.dart';

class TaskCalendar extends StatelessWidget {
  final String selectedDayId;
  final String todayDayId;
  final Function(String) onNewDaySelected;

  final weekDays = const ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];

  const TaskCalendar({
    super.key,
    required this.selectedDayId,
    required this.todayDayId,
    required this.onNewDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    DateTime selectedDate = DateTime.parse(selectedDayId);
    DateTime todayDate = DateTime.parse(todayDayId);
    var firstDayThisMonth = DateTime(selectedDate.year, selectedDate.month, 1);
    var firstDayNextMonth = DateTime(
      selectedDate.year,
      selectedDate.month + 1,
      1,
    );

    final int firstDayIndex = firstDayThisMonth.weekday - 1;
    final int daysCount = firstDayNextMonth
        .difference(firstDayThisMonth)
        .inDays;
    final int selectedDayIndex = firstDayIndex + selectedDate.day - 1;
    final int? todayDayIndex =
        selectedDate.year == todayDate.year &&
            selectedDate.month == todayDate.month
        ? firstDayIndex + todayDate.day - 1
        : null;
    final String monthText = DateFormat('MMMM yyyy').format(selectedDate);

    bool isDayEnabled(DateTime day, DateTime today) {
      return day.isAtSameMomentAs(today) || day.isAfter(today);
    }

    return Column(
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () {
                if (selectedDate.month == todayDate.month &&
                    selectedDate.year == todayDate.year) {
                  return;
                }

                DateTime newDate = DateTime(
                  selectedDate.year,
                  selectedDate.month - 1,
                  selectedDate.year == todayDate.year &&
                          selectedDate.month - 1 == todayDate.month
                      ? todayDate.day
                      : 1,
                );
                String newDay = DateFormat('yyyy-MM-dd').format(newDate);
                onNewDaySelected(newDay);
              },
              child: Icon(
                Icons.arrow_left_rounded,
                color:
                    selectedDate.month == todayDate.month &&
                        selectedDate.year == todayDate.year
                    ? AppColors.secondaryLightTextColor
                    : AppColors.primaryLightTextColor,
                size: 40.0,
              ),
            ),
            Expanded(
              child: Text(
                monthText,
                textAlign: TextAlign.center,
                style: AppTextStyles.content.copyWith(
                  color: AppColors.primaryLightTextColor,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                String newDay = DateFormat('yyyy-MM-dd').format(
                  DateTime(selectedDate.year, selectedDate.month + 1, 1),
                );
                onNewDaySelected(newDay);
              },
              child: Icon(
                Icons.arrow_right_rounded,
                color: AppColors.primaryLightTextColor,
                size: 40.0,
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            for (int i = 0; i < weekDays.length; i++)
              Expanded(
                child: Center(
                  child: Text(
                    weekDays[i],
                    style: AppTextStyles.content.copyWith(
                      color: AppColors.primaryLightTextColor,
                    ),
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: 8.0),
        GridView.count(
          crossAxisCount: 7,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          children: List.generate(
            firstDayIndex + daysCount,
            (i) => TaskCalendarDay(
              day: (i >= firstDayIndex && i < firstDayIndex + daysCount)
                  ? i - firstDayIndex + 1
                  : null,
              isEnabled: isDayEnabled(
                DateTime(
                  selectedDate.year,
                  selectedDate.month,
                  i - firstDayIndex + 1,
                ),
                todayDate,
              ),
              isToday: i == todayDayIndex,
              isSelected: i == selectedDayIndex,
              onSelected: () {
                String newDay = DateFormat('yyyy-MM-dd').format(
                  DateTime(
                    selectedDate.year,
                    selectedDate.month,
                    i - firstDayIndex + 1,
                  ),
                );
                onNewDaySelected(newDay);
              },
            ),
          ),
        ),
      ],
    );
  }
}
