import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vedem/core/pages/update_task_page.dart';
import 'package:vedem/core/style/app_style.dart';
import 'package:vedem/core/style/app_text_styles.dart';
import 'package:vedem/features/tasks/presentation/bloc/tasks_bloc.dart';

class TaskWidgetBody extends StatelessWidget {
  const TaskWidgetBody({
    super.key,
    required this.dayId,
    required this.color,
    required this.content,
    required this.diamonds,
    required this.isRecurring,
    required this.isDone,
    required this.taskId,
  });

  final String? dayId;
  final int taskId;
  final Color color;
  final String content;
  final bool isRecurring;
  final int diamonds;
  final bool isDone;

  IconData _getIcon(bool isRecurring, bool isDone) {
    if (isDone) {
      return Icons.done_rounded;
    }
    if (isRecurring) {
      return Icons.repeat_rounded;
    }
    return Icons.task_alt_rounded;
  }

  String _getText(bool isRecurring, bool isDone) {
    if (isDone) {
      return 'Done';
    }
    if (isRecurring) {
      return 'Daily task';
    }
    return 'Normal task';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: color.withAlpha(64),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(_getIcon(isRecurring, isDone), color: color, size: 16.0),
              SizedBox(width: 4.0),
              Text(
                _getText(isRecurring, isDone),
                style: AppTextStyles.content.copyWith(color: color),
              ),
              Spacer(),
              Text(
                'Task ID: $taskId',
                style: AppTextStyles.content.copyWith(color: color),
              ),
            ],
          ),
          SizedBox(height: 4.0),
          Text(
            content,
            style: AppTextStyles.heading.copyWith(
              color: color,
              decorationColor: color,
              decoration: isDone
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
            ),
          ),
          SizedBox(height: 4.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                diamonds.toString(),
                style: AppTextStyles.heading.copyWith(color: color),
              ),
              SizedBox(width: 2.0),
              Icon(Icons.diamond_rounded, size: 16.0, color: color),
              Spacer(),
              GestureDetector(
                onTap: () {
                  UpdateTaskPage.route(context, taskId);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: color.withAlpha(70),
                    borderRadius: BorderRadius.circular(
                      AppStyle.roundedCorners,
                    ),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: Icon(Icons.update_rounded, color: color, size: 16.0),
                ),
              ),
              SizedBox(width: 4.0),
              GestureDetector(
                onTap: () {
                  context.read<TasksBloc>().add(
                    DeleteTaskEvent(dayId: dayId, taskId: taskId),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: color.withAlpha(70),
                    borderRadius: BorderRadius.circular(
                      AppStyle.roundedCorners,
                    ),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: Icon(Icons.delete_rounded, color: color, size: 16.0),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
