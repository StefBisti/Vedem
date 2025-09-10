import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vedem/core/style/app_text_styles.dart';
import 'package:vedem/features/tasks/domain/entities/task_entity.dart';
import 'package:vedem/features/tasks/presentation/bloc/tasks_bloc.dart';
import 'package:vedem/features/tasks/presentation/private/task_widget.dart';

class ListTasksDisplay extends StatefulWidget {
  const ListTasksDisplay({super.key});

  @override
  State<ListTasksDisplay> createState() => _ListTasksDisplayState();
}

class _ListTasksDisplayState extends State<ListTasksDisplay> {
  final categoryColors = const [
    Colors.red,
    Colors.blue,
    Colors.orange,
    Colors.purple,
    Colors.black,
  ];

  late TextEditingController dayController,
      monthController,
      createTaskDayController;

  @override
  void initState() {
    super.initState();
    dayController = TextEditingController();
    monthController = TextEditingController();
    createTaskDayController = TextEditingController();
  }

  @override
  void dispose() {
    dayController.dispose();
    monthController.dispose();
    createTaskDayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TasksBloc, TasksState>(
      builder: (context, state) {
        return Padding(
          padding: EdgeInsetsGeometry.symmetric(horizontal: 16.0),
          child: SingleChildScrollView(
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
                Text('Tasks this month', style: AppTextStyles.heading),
                for (TaskEntity task in state.tasks)
                  TaskWidget(
                    dayId: null,
                    task: task,
                    categoryColors: categoryColors,
                  ),

                SizedBox(height: 60.0),

                SizedBox(height: 60.0),
              ],
            ),
          ),
        );
      },
    );
  }
}
