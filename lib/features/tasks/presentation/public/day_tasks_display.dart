import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vedem/core/pages/create_task_page.dart';
import 'package:vedem/core/style/app_colors.dart';
import 'package:vedem/core/style/app_style.dart';
import 'package:vedem/core/style/app_text_styles.dart';
import 'package:vedem/core/utils/misc_utils.dart';
import 'package:vedem/features/tasks/domain/entities/task_entity.dart';
import 'package:vedem/features/tasks/presentation/bloc/tasks_bloc.dart';
import 'package:vedem/features/tasks/presentation/private/task_widget.dart';
import 'package:animations/animations.dart';

class DayTasksDisplay extends StatefulWidget {
  final String dayId;

  const DayTasksDisplay({super.key, required this.dayId});

  @override
  State<DayTasksDisplay> createState() => _DayTasksDisplayState();
}

class _DayTasksDisplayState extends State<DayTasksDisplay> {
  final categoryColors = const [
    Colors.green,
    Colors.blue,
    Colors.red,
    Colors.amber,
    Colors.black,
  ];

  late TextEditingController dayController, monthController;

  @override
  void initState() {
    super.initState();
    dayController = TextEditingController();
    monthController = TextEditingController();
  }

  @override
  void dispose() {
    dayController.dispose();
    monthController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TasksBloc, TasksState>(
      listener: (context, state) {
        if (state.error != null) {
          MiscUtils.showSnackBar(context, state.error!);
        }
      },
      builder: (context, state) {
        bool anyTasksDone = state.tasks.any((t) => t.isDone == true);
        bool anyTasksUnone = state.tasks.any((t) => t.isDone == false);
        return Padding(
          padding: EdgeInsetsGeometry.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8.0,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('Tasks left today', style: AppTextStyles.heading),
                  SizedBox(width: 16.0),
                  if (state.isLoading)
                    CircularProgressIndicator(
                      constraints: BoxConstraints(
                        minWidth: 15.0,
                        maxWidth: 15.0,
                        minHeight: 15.0,
                        maxHeight: 15.0,
                      ),
                      color: AppColors.primaryDarkTextColor,
                      strokeWidth: 3.0,
                    ),
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
                    openBuilder: (context, _) {
                      return CreateTaskPage(
                        dayId: widget.dayId,
                        tasksBloc: this.context.read<TasksBloc>(),
                      );
                    },
                  ),
                ],
              ),

              for (TaskEntity task in state.tasks)
                if (task.isDone == false)
                  TaskWidget(
                    key: ValueKey(task.taskId),
                    dayId: widget.dayId,
                    task: task,
                    categoryColors: categoryColors,
                  ),
              if (anyTasksUnone == false && anyTasksDone == true)
                Text('No tasks left! Well done!', style: AppTextStyles.content),
              if (anyTasksUnone == false && anyTasksDone == false)
                Text(
                  'No tasks for today. Add some',
                  style: AppTextStyles.content,
                ),

              if (anyTasksDone) ...[
                SizedBox(height: 20.0),
                Text('Tasks done today', style: AppTextStyles.heading),
                for (TaskEntity task in state.tasks)
                  if (task.isDone == true)
                    TaskWidget(
                      key: ValueKey(task.taskId),
                      dayId: widget.dayId,
                      task: task,
                      categoryColors: categoryColors,
                    ),
              ],

              // Create new task part
              SizedBox(height: 20.0),

              // Initialize day part
              TextButton.icon(
                onPressed: () {
                  context.read<TasksBloc>().add(
                    InitializeTasksForDayEvent(dayId: widget.dayId),
                  );
                },
                label: Text(
                  'Initialize day with tasks',
                  style: AppTextStyles.content.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryLightTextColor,
                  ),
                ),
                icon: Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.primaryLightTextColor,
                  size: 20.0,
                ),
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(
                      AppStyle.roundedCorners,
                    ),
                  ),
                  backgroundColor: AppColors.darkBackgroundColor,
                ),
              ),

              SizedBox(height: 32.0),

              
            ],
          ),
        );
      },
    );
  }
}
