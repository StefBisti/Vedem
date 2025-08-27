import 'package:flutter/material.dart';
import 'package:vedem/core/style/app_colors.dart';
import 'package:vedem/core/style/app_style.dart';
import 'package:vedem/core/style/app_text_styles.dart';

class CreateTaskTextField extends StatelessWidget {
  const CreateTaskTextField({
    super.key,
    required this.color,
    required this.controller,
  });

  final Color color;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      cursorColor: AppColors.primaryLightTextColor,
      cursorErrorColor: Colors.red,
      cursorRadius: Radius.circular(double.infinity),
      style: AppTextStyles.heading.copyWith(color: color),
      maxLines: null,
      minLines: 1,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppStyle.roundedCorners),
          borderSide: BorderSide(
            color: AppColors.secondaryLightTextColor,
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppStyle.roundedCorners),
          borderSide: BorderSide(
            color: AppColors.secondaryLightTextColor,
            width: 1.0,
          ),
        ),
      ),
    );
  }
}
