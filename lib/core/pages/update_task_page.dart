import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:vedem/core/style/app_text_styles.dart';
import 'package:vedem/features/tasks/presentation/bloc/tasks_bloc.dart';
import 'package:vedem/features/tasks/presentation/public/update_task_display.dart';

class UpdateTaskPage extends StatelessWidget {
  static void route(BuildContext context, int taskId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UpdateTaskPage(taskId: taskId)),
    );
  }

  final int taskId;

  const UpdateTaskPage({super.key, required this.taskId});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider(create: (_) => GetIt.instance<TasksBloc>())],
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          title: Text(
            'Update task with id $taskId',
            style: AppTextStyles.heading,
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [UpdateTaskDisplay(taskId: taskId)],
          ),
        ),
      ),
    );
  }
}
