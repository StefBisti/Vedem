import 'package:flutter/material.dart';
import 'package:vedem/core/style/app_style.dart';
import 'package:vedem/core/style/app_text_styles.dart';
import 'package:vedem/core/utils/time_utils.dart';
import 'package:vedem/features/tasks/domain/entities/task_done_type.dart';
import 'package:vedem/features/tasks/domain/entities/task_entity.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class TaskWidgetBody extends StatelessWidget {
  final TaskEntity task;
  final Color primaryColor;
  final Color secondaryColor;
  final Function()? onEdit;
  final Function()? onDelete;
  final Function(int, bool) onSubtaskToggled;

  const TaskWidgetBody({
    super.key,
    required this.task,
    required this.primaryColor,
    required this.secondaryColor,
    required this.onEdit,
    required this.onDelete,
    required this.onSubtaskToggled,
  });

  IconData _getLeftIcon(TaskEntity task) {
    if (task.taskDoneType == TaskDoneType.awesome) {
      return Icons.sentiment_very_satisfied_rounded;
    }
    if (task.taskDoneType == TaskDoneType.onPoint) {
      if (task.onPointDiamonds == null) {
        return Icons.check_rounded;
      } else {
        return Icons.sentiment_satisfied_rounded;
      }
    }
    if (task.taskDoneType == TaskDoneType.notGreat) {
      return Icons.sentiment_dissatisfied_rounded;
    }
    // if (task.isDailyTask && task.onPointDiamonds == null) {
    //   return Icons.notifications_active_outlined;
    // }
    // if (task.isDailyTask) {
    //   return Icons.repeat_rounded;
    // }
    // if (task.onPointDiamonds == null) {
    //   return Icons.notifications_active_outlined;
    // }
    // if (task.taskType == TaskType.secondChance) {
    //   return Icons.restart_alt_rounded;
    // }
    // if (task.taskType == TaskType.bestValue) {
    //   return Icons.workspace_premium_rounded;
    // }
    return Icons.task_alt_rounded;
  }

  String _getLeftText(TaskEntity task) {
    if (task.taskDoneType == TaskDoneType.awesome) {
      return 'Done - Awesome';
    }
    if (task.taskDoneType == TaskDoneType.onPoint) {
      if (task.onPointDiamonds == null) {
        return 'Done';
      } else {
        return 'Done - On point';
      }
    }
    if (task.taskDoneType == TaskDoneType.notGreat) {
      return 'Done - Not great';
    }
    // if (task.isDailyTask && task.onPointDiamonds == null) {
    //   return 'Daily reminder';
    // }
    // if (task.isDailyTask) {
    //   return 'Daily task';
    // }
    // if (task.onPointDiamonds == null) {
    //   return 'Reminder';
    // }
    // if (task.taskType == TaskType.secondChance) {
    //   return 'Second chance';
    // }
    // if (task.taskType == TaskType.bestValue) {
    //   return 'Best value';
    // }
    return 'Regular task';
  }

  IconData? _getRightIcon(TaskEntity task) {
    if (task.dueTimeInMinutes != null) {
      return Icons.access_time_rounded;
    }
    if (task.taskImportance != null && task.taskImportance! >= 5) {
      return Icons.error_outline_rounded;
    }
    if (task.timeRequired != null && task.timeRequired! <= 5) {
      return Icons.timer_outlined;
    }
    if (task.taskImportance != null && task.taskImportance! == 4) {
      return Icons.error_outline_rounded;
    }
    return null;
  }

  String? _getRightText(TaskEntity task) {
    if (task.dueTimeInMinutes != null) {
      return 'due ${TimeUtils.minutesToTimeString(task.dueTimeInMinutes!)}';
    }
    if (task.taskImportance != null && task.taskImportance! >= 5) {
      return 'Urgently important';
    }
    if (task.timeRequired != null && task.timeRequired! <= 5) {
      return 'Only ${task.timeRequired!} minutes';
    }
    if (task.taskImportance != null && task.taskImportance! == 4) {
      return 'Majorly important';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadiusGeometry.circular(AppStyle.roundedCorners),
      child: Slidable(
        key: Key('slide${task.taskId}'),
        startActionPane: onEdit == null
            ? null
            : ActionPane(
                motion: const DrawerMotion(),
                extentRatio: 0.2,
                children: [
                  SlidableAction(
                    onPressed: (_) {
                      onEdit!();
                    },
                    backgroundColor: primaryColor,
                    foregroundColor: secondaryColor,
                    icon: Icons.edit_rounded,
                  ),
                ],
              ),
        endActionPane: onDelete == null
            ? null
            : ActionPane(
                motion: const DrawerMotion(),
                extentRatio: 0.2,
                children: [
                  SlidableAction(
                    onPressed: (_) {
                      onDelete!();
                    },
                    backgroundColor: primaryColor,
                    foregroundColor: secondaryColor,
                    icon: Icons.delete_rounded,
                  ),
                ],
              ),

        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(color: secondaryColor),
              padding: EdgeInsets.only(
                left: 12.0,
                right: 12.0,
                top: 8.0,
                bottom: 10.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(_getLeftIcon(task), color: primaryColor, size: 16.0),
                      SizedBox(width: 4.0),
                      Text(
                        _getLeftText(task),
                        style: AppTextStyles.content.copyWith(
                          color: primaryColor,
                        ),
                      ),
                      Spacer(),
                      Icon(
                        _getRightIcon(task),
                        color: primaryColor,
                        size: 16.0,
                      ),
                      SizedBox(width: 4.0),
                      Text(
                        _getRightText(task) ?? '',
                        style: AppTextStyles.content.copyWith(
                          color: primaryColor,
                        ),
                      ),
                      if (task.isStarred) SizedBox(width: 24.0),
                    ],
                  ),
                  SizedBox(height: 4.0),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    spacing: 16.0,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              task.content,
                              style: AppTextStyles.heading.copyWith(
                                color: primaryColor,
                                decorationColor: primaryColor,
                                decorationThickness: 1.5,
                                decoration:
                                    task.taskDoneType != TaskDoneType.notDone
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                              ),
                            ),
                            if (task.subtasks.isNotEmpty) SizedBox(height: 4.0),
                            for (int i = 0; i < task.subtasks.length; i++)
                              GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  onSubtaskToggled(
                                    i,
                                    !task.subtasks[i].completed,
                                  );
                                },
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  spacing: 8.0,
                                  children: [
                                    Container(
                                      width: 16.0,
                                      height: 16.0,
                                      margin: EdgeInsets.only(top: 2.0),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          4.0,
                                        ),
                                        border: BoxBorder.all(
                                          color: primaryColor,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Center(
                                        child: AnimatedContainer(
                                          duration: Duration(milliseconds: 100),
                                          curve: Curves.easeOut,
                                          width: task.subtasks[i].completed
                                              ? 10.0
                                              : 0.0,
                                          height: task.subtasks[i].completed
                                              ? 10.0
                                              : 0.0,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              2.0,
                                            ),
                                            color: primaryColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        task.subtasks[i].content,
                                        style: AppTextStyles.content.copyWith(
                                          color: primaryColor,
                                          decorationColor: primaryColor,
                                          decorationThickness: 1.5,
                                          decoration: task.subtasks[i].completed
                                              ? TextDecoration.lineThrough
                                              : TextDecoration.none,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (task.onPointDiamonds != null)
                        Row(
                          spacing: 4.0,
                          children: [
                            Text(
                              task.getDiamonds(task.taskDoneType).toString(),
                              style: AppTextStyles.heading.copyWith(
                                color: primaryColor,
                              ),
                            ),
                            Icon(
                              Icons.diamond_rounded,
                              color: primaryColor,
                              size: 20.0,
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
            if (task.isStarred)
              Positioned(
                right: 0,
                top: 0,
                child: GestureDetector(
                  onTap: () {
                    // Unstar
                  },
                  child: Container(
                    padding: EdgeInsets.all(4.0),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.zero,
                        bottomLeft: Radius.circular(AppStyle.roundedCorners),
                        bottomRight: Radius.zero,
                        topRight: Radius.zero,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.star_rounded,
                        color: secondaryColor,
                        size: 18.0,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
