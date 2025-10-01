import 'package:flutter/material.dart';
import 'package:vedem/core/style/app_colors.dart';
import 'package:vedem/core/style/app_text_styles.dart';
import 'package:vedem/features/tasks/presentation/private/other/task_time_chooser_part.dart';

class TaskTimeChooser extends StatefulWidget {
  final bool enabled;
  final Function(int) onChanged;
  final int startTimeInMinutes;

  const TaskTimeChooser({
    super.key,
    required this.enabled,
    required this.onChanged,
    required this.startTimeInMinutes,
  });

  @override
  State<TaskTimeChooser> createState() => _TaskTimeChooserState();
}

class _TaskTimeChooserState extends State<TaskTimeChooser> {
  int hours = 0;
  int minutes = 0;

  @override
  void initState() {
    super.initState();
    hours = widget.startTimeInMinutes ~/ 60;
    minutes = widget.startTimeInMinutes % 60;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TaskTimeChooserPart(
          enabled: widget.enabled,
          onChanged: (h) {
            hours = h;
            widget.onChanged(hours * 60 + minutes);
          },
          min: 0,
          max: 23,
          value: hours.toDouble(),
          minColor: Colors.transparent,
          maxColor: AppColors.primaryLightTextColor,
          disabledMaxColor: AppColors.secondaryLightTextColor,
          translationCurve: Curves.easeOutQuad,
          rotationCurve: Curves.easeOut,
          scalationCurve: Curves.linear,
          colorCurve: Curves.easeInCubic,
          fullColorThreshold: 0.2,
        ),
        SizedBox(width: 8.0),
        Text(
          ':',
          style: AppTextStyles.heading.copyWith(
            color: widget.enabled
                ? AppColors.primaryLightTextColor
                : AppColors.secondaryLightTextColor,
          ),
        ),
        SizedBox(width: 8.0),
        TaskTimeChooserPart(
          enabled: widget.enabled,
          onChanged: (m) {
            minutes = m;
            widget.onChanged(hours * 60 + minutes);
          },
          min: 0,
          max: 59,
          value: minutes.toDouble(),
          minColor: Colors.transparent,
          maxColor: AppColors.primaryLightTextColor,
          disabledMaxColor: AppColors.secondaryLightTextColor,
          translationCurve: Curves.easeOutQuad,
          rotationCurve: Curves.easeOut,
          scalationCurve: Curves.linear,
          colorCurve: Curves.easeInCubic,
          fullColorThreshold: 0.2,
        ),
      ],
    );
  }
}
