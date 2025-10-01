import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vedem/core/pages/create_task_page.dart';
import 'package:vedem/core/pages/update_task_page.dart';
import 'package:vedem/core/style/app_colors.dart';
import 'package:vedem/core/style/app_style.dart';
import 'package:vedem/core/style/app_text_styles.dart';
import 'package:vedem/core/utils/misc_utils.dart';
import 'package:vedem/features/tasks/domain/entities/task_done_type.dart';
import 'package:vedem/features/tasks/domain/entities/task_entity.dart';
import 'package:vedem/features/tasks/presentation/cubit/tasks_cubit.dart';
import 'package:vedem/features/tasks/presentation/private/task/task_widget.dart';
import 'package:animations/animations.dart';

class DayTasksDisplay extends StatelessWidget {
  final String dayId;

  DayTasksDisplay({super.key, required this.dayId});

  final categoryPrimaryColors = const [
    AppColors.primaryColor1,
    AppColors.primaryColor2,
    AppColors.primaryColor0,
    AppColors.primaryColor3,
  ];
  final categorySecondaryColors = [
    AppColors.secondaryColor1Light,
    AppColors.secondaryColor2Light,
    AppColors.secondaryColor0Light,
    AppColors.secondaryColor3Light,
  ];

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TasksCubit, TasksState>(
      listener: (ctx, state) {
        if (state.error != null) {
          MiscUtils.showSnackBar(context, state.error!);
        }
      },
      builder: (ctx, state) {
        bool anyTasksDone = state.tasks.any(
          (t) => t.taskDoneType != TaskDoneType.notDone,
        );
        bool anyTasksNotDone = state.tasks.any(
          (t) => t.taskDoneType == TaskDoneType.notDone,
        );
        return Padding(
          padding: EdgeInsetsGeometry.symmetric(
            horizontal: AppStyle.pageHorizontalPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8.0,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('Tasks left today', style: AppTextStyles.heading),
                  Spacer(),
                  OpenContainer(
                    closedElevation: 0,
                    openElevation: 0,
                    closedColor: AppColors.darkBackgroundColor,
                    openColor: AppColors.darkBackgroundColor,
                    closedShape: RoundedRectangleBorder(
                      borderRadius: BorderRadiusGeometry.circular(
                        AppStyle.roundedCorners,
                      ),
                    ),
                    openShape: RoundedRectangleBorder(
                      borderRadius: BorderRadiusGeometry.circular(
                        AppStyle.roundedCorners,
                      ),
                    ),
                    closedBuilder: (context, openContainer) {
                      return SizedBox(
                        child: TextButton.icon(
                          onPressed: openContainer,
                          label: Text(
                            'Add',
                            style: AppTextStyles.content.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryLightTextColor,
                            ),
                          ),
                          icon: Icon(
                            Icons.add_rounded,
                            color: AppColors.primaryLightTextColor,
                            size: 20.0,
                          ),
                          style: TextButton.styleFrom(
                            visualDensity: VisualDensity(
                              horizontal: VisualDensity.minimumDensity,
                              vertical: VisualDensity.minimumDensity,
                            ),
                            padding: EdgeInsets.only(left: 8.0, right: 12.0),
                          ),
                        ),
                      );
                    },
                    openBuilder: (_, _) {
                      return CreateTaskPage(
                        dayId: dayId,
                        tasksBloc: ctx.read<TasksCubit>(),
                      );
                    },
                  ),
                ],
              ),

              for (TaskEntity task in state.tasks)
                if (task.taskDoneType == TaskDoneType.notDone)
                  _getTaskWidget(task, context),

              if (anyTasksNotDone == false && anyTasksDone == true)
                Text('No tasks left! Well done!', style: AppTextStyles.content),
              if (anyTasksNotDone == false && anyTasksDone == false)
                Text(
                  'No tasks for today. Add some',
                  style: AppTextStyles.content,
                ),

              if (anyTasksDone) ...[
                SizedBox(height: 20.0),
                Text('Tasks done today', style: AppTextStyles.heading),
                for (TaskEntity task in state.tasks)
                  if (task.taskDoneType != TaskDoneType.notDone)
                    _getTaskWidget(task, context),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _getTaskWidget(TaskEntity task, BuildContext context) {
    return TaskWidget(
      key: ValueKey(task.taskId),
      task: task,
      categoryPrimaryColor:
          categoryPrimaryColors[min(
            task.categoryId,
            categoryPrimaryColors.length - 1,
          )],
      categorySecondaryColor:
          categorySecondaryColors[min(
            task.categoryId,
            categoryPrimaryColors.length - 1,
          )],
      onEdit: () {
        UpdateTaskPage.route(context, task.taskId, context.read<TasksCubit>());
      },
      onDelete: () {
        context.read<TasksCubit>().deleteTask(task.taskId);
      },
      onTaskToggled: (doneType) {
        context.read<TasksCubit>().toggleTask(task.dayTaskId!, doneType);
      },
      onSubstaskToggled: (index, completed) {
        context.read<TasksCubit>().toggleSubtask(
          task.dayTaskId!,
          index,
          completed,
        );
      },
      onClaimDiamonds: (diamonds) {
        // TODO
      },
      onTaskPressed: null,
    );
  }
}
