import 'package:flutter/material.dart';
import 'package:vedem/core/style/app_colors.dart';

class DayShareButtonDisplay extends StatelessWidget {
  const DayShareButtonDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'share',
      mini: true,
      backgroundColor: AppColors.lightBackgroundColor,
      foregroundColor: AppColors.primaryDarkTextColor,
      shape: CircleBorder(),
      child: Transform.translate(
        offset: Offset(0, 0),
        child: Icon(
          Icons.ios_share,
          color: AppColors.primaryDarkTextColor,
          size: 24.0,
        ),
      ),
      onPressed: () {
        // print("share");
      },
    );
  }
}
