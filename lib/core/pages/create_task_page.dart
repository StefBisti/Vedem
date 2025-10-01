import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vedem/core/style/app_colors.dart';
import 'package:vedem/features/tasks/presentation/cubit/tasks_cubit.dart';
import 'package:vedem/features/tasks/presentation/public/create_task_display.dart';

class CreateTaskPage extends StatelessWidget {
  final String dayId;
  final TasksCubit tasksBloc;

  const CreateTaskPage({
    super.key,
    required this.dayId,
    required this.tasksBloc,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: tasksBloc,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 0.0,
          scrolledUnderElevation: 0.0,
          elevation: 0.0,
          backgroundColor: AppColors.darkBackgroundColor.withAlpha(100),
        ),
        backgroundColor: AppColors.darkBackgroundColor,
        extendBodyBehindAppBar: true,
        body: CreateTaskDisplay(dayId: dayId),
      ),
    );
  }
}
