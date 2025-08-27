import 'package:flutter/material.dart';
import 'package:vedem/core/style/app_colors.dart';
import 'package:vedem/core/style/app_style.dart';
import 'package:vedem/core/style/app_text_styles.dart';

class CreateTaskRecurring extends StatefulWidget {
  const CreateTaskRecurring({super.key, required this.onChanged});

  final Function(bool?) onChanged;

  @override
  State<CreateTaskRecurring> createState() => _CreateTaskRecurringState();
}

class _CreateTaskRecurringState extends State<CreateTaskRecurring> {
  bool recurring = false;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: recurring,
      onChanged: (v) {
        widget.onChanged(v);
        setState(() {
          recurring = v!;
        });
      },
      title: Text(
        'Recurring',
        style: AppTextStyles.content.copyWith(color: AppColors.primaryLightTextColor),
      ),
      dense: true,
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.all(0.0),
      activeColor: AppColors.primaryLightTextColor,
      checkColor: AppColors.primaryDarkTextColor,
      visualDensity: VisualDensity.compact,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(AppStyle.roundedCorners),
      ),
    );
  }
}
