import 'package:flutter/material.dart';
import 'package:vedem/core/style/app_colors.dart';
import 'package:vedem/core/style/app_style.dart';
import 'package:vedem/core/style/app_text_styles.dart';

class CreateTaskStepper extends StatefulWidget {
  const CreateTaskStepper({
    super.key,
    required this.onChanged,
    required this.steppers,
    required this.display,
    required this.min,
    required this.max,
  });

  final Function(int) onChanged;
  final List<int> steppers;
  final int min, max;
  final String Function(int) display;

  @override
  State<CreateTaskStepper> createState() => _CreateTaskStepperState();
}

class _CreateTaskStepperState extends State<CreateTaskStepper> {
  int value = 0, step = 0, incrementToApply = 0;

  void _onLeftPressed() {
    if (value <= widget.min) return;

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
    if (value >= widget.max) return;

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
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: _onLeftPressed,
            icon: Icon(
              Icons.arrow_left_rounded,
              color: AppColors.primaryLightTextColor,
              size: 40.0,
            ),
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            style: IconButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadiusGeometry.circular(
                  AppStyle.roundedCorners,
                ),
                side: BorderSide(
                  color: AppColors.primaryLightTextColor,
                  width: 1.0,
                ),
              ),
            ),
          ),
          SizedBox(width: 16.0),
          Text(
            widget.display(value),
            style: AppTextStyles.heading.copyWith(
              color: AppColors.primaryLightTextColor,
            ),
          ),
          SizedBox(width: 16.0),
          IconButton(
            onPressed: _onRightPressed,
            icon: Icon(
              Icons.arrow_right_rounded,
              color: AppColors.primaryLightTextColor,
              size: 40.0,
            ),
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            style: IconButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadiusGeometry.circular(
                  AppStyle.roundedCorners,
                ),
                side: BorderSide(
                  color: AppColors.primaryLightTextColor,
                  width: 1.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
