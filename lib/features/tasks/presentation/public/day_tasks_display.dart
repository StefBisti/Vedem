import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vedem/core/pages/create_task_page.dart';
import 'package:vedem/core/pages/day_page.dart';
import 'package:vedem/core/pages/month_page.dart';
import 'package:vedem/core/style/app_colors.dart';
import 'package:vedem/core/style/app_style.dart';
import 'package:vedem/core/style/app_text_styles.dart';
import 'package:vedem/features/tasks/domain/entities/task_entity.dart';
import 'package:vedem/features/tasks/presentation/bloc/tasks_bloc.dart';
import 'package:vedem/features/tasks/presentation/private/task_widget.dart';

class DayTasksDisplay extends StatefulWidget {
  final String dayId;

  const DayTasksDisplay({super.key, required this.dayId});

  @override
  State<DayTasksDisplay> createState() => _DayTasksDisplayState();
}

class _DayTasksDisplayState extends State<DayTasksDisplay> {
  final categoryColors = const [
    Colors.red,
    Colors.blue,
    Colors.orange,
    Colors.purple,
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
    return BlocBuilder<TasksBloc, TasksState>(
      builder: (context, state) {
        bool shouldDisplayTasksDone = state.tasks.any((t) => t.isDone == true);
        return Padding(
          padding: EdgeInsetsGeometry.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8.0,
            children: [
              // Is loading & Error Part
              Row(
                children: [
                  Text(
                    'Is loading: ${state.isLoading}    ',
                    style: AppTextStyles.content,
                  ),
                  Container(
                    width: 10.0,
                    height: 10.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      color: state.isLoading ? Colors.red : Colors.green,
                    ),
                  ),
                ],
              ),
              Text('Error: ${state.error}', style: AppTextStyles.content),

              // Tasks part
              SizedBox(height: 20.0),
              Text('Tasks left today', style: AppTextStyles.heading),
              for (TaskEntity task in state.tasks)
                if (task.isDone == false)
                  TaskWidget(
                    key: ValueKey(task.taskId),
                    dayId: widget.dayId,
                    task: task,
                    categoryColors: categoryColors,
                  ),

              if (shouldDisplayTasksDone) ...[
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
              TextButton.icon(
                onPressed: () {
                  CreateTaskPage.route(context, widget.dayId);
                },
                label: Text(
                  'Create new task today',
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(
                      AppStyle.roundedCorners,
                    ),
                  ),
                  backgroundColor: AppColors.darkBackgroundColor,
                ),
              ),

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

              // Read tasks for day part
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () {
                      DayPage.route(context, dayController.text);
                    },
                    label: Text(
                      'Read tasks for day',
                      style: AppTextStyles.content.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryLightTextColor,
                      ),
                    ),
                    icon: Icon(
                      Icons.calendar_view_day,
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
                  SizedBox(width: 20.0),
                  Expanded(
                    child: TextField(
                      style: AppTextStyles.content,
                      maxLines: 1,
                      minLines: 1,
                      controller: dayController,
                      decoration: InputDecoration(
                        labelText: 'Day',
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),

              // Read tasks for month part
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () {
                      MonthPage.route(context, monthController.text);
                    },
                    label: Text(
                      'Read tasks for month',
                      style: AppTextStyles.content.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryLightTextColor,
                      ),
                    ),
                    icon: Icon(
                      Icons.date_range,
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
                  SizedBox(width: 20.0),
                  Expanded(
                    child: TextField(
                      style: AppTextStyles.content,
                      maxLines: 1,
                      minLines: 1,
                      controller: monthController,
                      decoration: InputDecoration(
                        labelText: 'Month',
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 60.0),
            ],
          ),
        );
      },
    );
  }
}
