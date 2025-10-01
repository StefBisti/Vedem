import 'package:flutter/material.dart';
import 'package:vedem/core/style/app_colors.dart';
import 'package:vedem/core/style/app_style.dart';
import 'package:vedem/core/style/app_text_styles.dart';

class TaskStepper extends StatefulWidget {
  final bool enabled;
  final Function(int) onChanged;
  final List<int> steppers;
  final int start, min, max;
  final String Function(int) display;

  const TaskStepper({
    super.key,
    required this.enabled,
    required this.onChanged,
    required this.steppers,
    required this.display,
    required this.start,
    required this.min,
    required this.max,
  });

  @override
  State<TaskStepper> createState() => _TaskStepperState();
}

class _TaskStepperState extends State<TaskStepper> {
  int value = 0, step = 0, incrementToApply = 0;

  void _onLeftPressed() {
    if (widget.enabled == false || value <= widget.min) return;

    if (step > 0) {
      step = 0;
      incrementToApply = 0;
    }
    while (widget.steppers[incrementToApply] <= -step) {
      incrementToApply++;
    }

    step--;
    value = (value - incrementToApply).clamp(widget.min, widget.max);
    widget.onChanged(value);
    setState(() {});
  }

  void _onRightPressed() {
    if (widget.enabled == false || value >= widget.max) return;

    if (step < 0) {
      step = 0;
      incrementToApply = 0;
    }
    while (widget.steppers[incrementToApply] <= step) {
      incrementToApply++;
    }

    step++;
    value = (value + incrementToApply).clamp(widget.min, widget.max);
    widget.onChanged(value);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    value = widget.start;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 40.0,
            height: 40.0,
            child: IconButton(
              onPressed: _onLeftPressed,
              icon: Transform.translate(
                offset: Offset(-10, -10),
                child: Icon(
                  Icons.arrow_left_rounded,
                  color: (widget.enabled && value > widget.min)
                      ? AppColors.primaryLightTextColor
                      : AppColors.secondaryLightTextColor,
                  size: 60.0,
                ),
              ),
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
              style: IconButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.circular(
                    AppStyle.roundedCorners,
                  ),
                  side: BorderSide(color: Colors.transparent, width: 1.5),
                ),
              ),
            ),
          ),
          SizedBox(width: 16.0),
          Text(
            widget.display(value),
            style: AppTextStyles.heading.copyWith(
              color: widget.enabled
                  ? AppColors.primaryLightTextColor
                  : AppColors.secondaryLightTextColor,
            ),
          ),
          SizedBox(width: 16.0),
          SizedBox(
            width: 40.0,
            height: 40.0,
            child: IconButton(
              onPressed: _onRightPressed,
              icon: Transform.translate(
                offset: Offset(-10, -10),
                child: Icon(
                  Icons.arrow_right_rounded,
                  color: (widget.enabled && value < widget.max)
                      ? AppColors.primaryLightTextColor
                      : AppColors.secondaryLightTextColor,
                  size: 60.0,
                ),
              ),
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
              style: IconButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.circular(
                    AppStyle.roundedCorners,
                  ),
                  side: BorderSide(color: Colors.transparent, width: 1.5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
