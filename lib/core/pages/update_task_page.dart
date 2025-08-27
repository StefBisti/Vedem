import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vedem/core/style/app_text_styles.dart';
import 'package:vedem/features/tasks/presentation/bloc/tasks_bloc.dart';
import 'package:vedem/features/tasks/presentation/public/update_task_display.dart';

class UpdateTaskPage extends StatelessWidget {
  final int taskId;

  const UpdateTaskPage({super.key, required this.taskId});

  static void route(BuildContext context, TasksBloc bloc, int taskId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: bloc,
          child: UpdateTaskPage(taskId: taskId),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
  }
}
