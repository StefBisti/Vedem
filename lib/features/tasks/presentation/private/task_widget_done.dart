import 'package:flutter/material.dart';
import 'package:vedem/core/style/app_text_styles.dart';

class TaskWidgetDone extends StatelessWidget {
  const TaskWidgetDone({super.key, required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: color.withAlpha(100),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_rounded, size: 24.0, color: color),
            SizedBox(width: 8.0),
            Text(
              'Completed',
              style: AppTextStyles.heading.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
