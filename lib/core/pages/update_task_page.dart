import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vedem/core/style/app_colors.dart';
import 'package:vedem/features/tasks/presentation/cubit/tasks_cubit.dart';
import 'package:vedem/features/tasks/presentation/public/update_task_display.dart';

class UpdateTaskPage extends StatelessWidget {
  final int taskId;
  final TasksCubit tasksCubit;

  const UpdateTaskPage({
    super.key,
    required this.taskId,
    required this.tasksCubit,
  });

  static void route(BuildContext context, int taskId, TasksCubit tasksCubit) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => UpdateTaskPage(taskId: taskId, tasksCubit: tasksCubit),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: tasksCubit,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 0.0,
          scrolledUnderElevation: 0.0,
          elevation: 0.0,
          backgroundColor: AppColors.darkBackgroundColor.withAlpha(0),
        ),
        backgroundColor: AppColors.darkBackgroundColor,
        extendBodyBehindAppBar: true,
        body: UpdateTaskDisplay(taskId: taskId),
      ),
    );
  }
}
