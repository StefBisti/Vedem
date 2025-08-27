import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vedem/core/style/app_colors.dart';
import 'package:vedem/features/tasks/presentation/bloc/tasks_bloc.dart';
import 'package:vedem/features/tasks/presentation/public/create_task_display.dart';

class CreateTaskPage extends StatelessWidget {
  final String dayId;

  const CreateTaskPage({super.key, required this.dayId});

  static void route(BuildContext context, TasksBloc bloc, String dayId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: bloc,
          child: CreateTaskPage(dayId: dayId),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0.0,
        scrolledUnderElevation: 0.0,
        elevation: 0.0,
        backgroundColor: AppColors.darkBackgroundColor.withAlpha(0),
      ),
      backgroundColor: AppColors.darkBackgroundColor,
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [CreateTaskDisplay(dayId: dayId)],
        ),
      ),
    );
  }
}
