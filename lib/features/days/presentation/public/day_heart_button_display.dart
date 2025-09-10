import 'package:flutter/material.dart';
import 'package:vedem/core/style/app_colors.dart';

class DayHeartButtonDisplay extends StatelessWidget {
  const DayHeartButtonDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'heart',
      mini: true,
      backgroundColor: AppColors.lightBackgroundColor,
      foregroundColor: AppColors.primaryDarkTextColor,
      shape: CircleBorder(),
      child: Icon(
        Icons.favorite_border,
        color: AppColors.primaryDarkTextColor,
        size: 24.0,
      ),
      onPressed: () {
        // print("heart");
      },
    );
  }
}
