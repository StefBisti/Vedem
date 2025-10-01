import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vedem/core/style/app_colors.dart';
import 'package:vedem/core/style/app_style.dart';
import 'package:vedem/core/style/app_text_styles.dart';
import 'package:vedem/core/utils/misc_utils.dart';
import 'package:vedem/features/tasks/domain/entities/task_entity.dart';
import 'package:vedem/features/tasks/domain/entities/task_filter_type.dart';
import 'package:vedem/features/tasks/presentation/cubit/tasks_cubit.dart';
import 'package:vedem/features/tasks/presentation/private/browse_tasks/task_filter_selector.dart';
import 'package:vedem/features/tasks/presentation/private/task/task_widget.dart';

class BrowseTasksDisplay extends StatefulWidget {
  const BrowseTasksDisplay({super.key});

  @override
  State<BrowseTasksDisplay> createState() => _BrowseTasksDisplayState();
}

class _BrowseTasksDisplayState extends State<BrowseTasksDisplay> {
  TaskFilterType selectedFilterType = TaskFilterType.byStarred;

  ///////////////////////////////////////////

  final List<String> categories = const [
    'Wellbeing',
    'Money',
    'Personality',
    'Academic',
  ];

  final List<IconData> icons = const [
    Icons.self_improvement,
    Icons.attach_money,
    Icons.psychology,
    Icons.school,
  ];
  final categoryPrimaryColors = const [
    AppColors.primaryColor1,
    AppColors.primaryColor2,
    AppColors.primaryColor0,
    AppColors.primaryColor3,
  ];

  final categorySecondaryColors = [
    AppColors.secondaryColor1Dark,
    AppColors.secondaryColor2Dark,
    AppColors.secondaryColor0Dark,
    AppColors.secondaryColor3Dark,
  ];

  ///////////////////////////////////////////

  String _getFilterText(TaskFilterType filterType) {
    switch (filterType) {
      case TaskFilterType.none:
        return 'All tasks';
      case TaskFilterType.byStarred:
        return 'Starred tasks';
      case TaskFilterType.byTrashed:
        return 'Trashed tasks';
      case TaskFilterType.byCategory0:
        return '${categories.isNotEmpty ? categories[0] : ''} tasks';
      case TaskFilterType.byCategory1:
        return '${categories.length > 1 ? categories[1] : ''} tasks';
      case TaskFilterType.byCategory2:
        return '${categories.length > 2 ? categories[2] : ''} tasks';
      case TaskFilterType.byCategory3:
        return '${categories.length > 3 ? categories[3] : ''} tasks';
      case TaskFilterType.byCategory4:
        return '${categories.length > 4 ? categories[4] : ''} tasks';
      case TaskFilterType.byCategory5:
        return '${categories.length > 5 ? categories[5] : ''} tasks';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TasksCubit, TasksState>(
      listener: (ctx, state) {
        if (state.error != null) {
          MiscUtils.showSnackBar(context, state.error!);
        }
      },
      builder: (ctx, state) {
        return Padding(
          padding: EdgeInsetsGeometry.symmetric(
            horizontal: AppStyle.pageHorizontalPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8.0,
            children: [
              const SizedBox(height: 16.0),
              TaskFilterSelector(
                labels: ['All', 'Starred', 'Trashed', ...categories],
                colors: [
                  AppColors.primaryLightTextColor,
                  AppColors.primaryLightTextColor,
                  AppColors.primaryLightTextColor,
                  ...categoryPrimaryColors,
                ],
                icons: [
                  Icons.folder_open,
                  Icons.star_rounded,
                  Icons.delete_rounded,
                  ...icons,
                ],
                selectedIndex: selectedFilterType.index,
                onSelected: (index) {
                  setState(() {
                    selectedFilterType = TaskFilterType.values[index];
                  });
                },
              ),
              Text(
                _getFilterText(selectedFilterType),
                style: AppTextStyles.heading.copyWith(
                  color: AppColors.primaryLightTextColor,
                ),
              ),

              for (TaskEntity task in state.tasks)
                _getTaskWidget(task, context),
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
      onEdit: null,
      onDelete: null,
      onTaskToggled: null,
      onSubstaskToggled: null,
      onClaimDiamonds: null,
      onTaskPressed: () {
        print('selected ${task.taskId}');
        Navigator.pop(context);
      },
    );
  }
}
