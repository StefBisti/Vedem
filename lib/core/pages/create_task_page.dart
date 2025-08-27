import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:vedem/core/style/app_text_styles.dart';
import 'package:vedem/features/tasks/presentation/bloc/tasks_bloc.dart';
import 'package:vedem/features/tasks/presentation/public/create_task_display.dart';

class CreateTaskPage extends StatelessWidget {
  static void route(BuildContext context, String dayId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateTaskPage(dayId: dayId)),
    );
  }

  final String dayId;

  const CreateTaskPage({super.key, required this.dayId});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider(create: (_) => GetIt.instance<TasksBloc>())],
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          title: Text(
            'Create New Task Page for $dayId',
            style: AppTextStyles.heading,
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [CreateTaskDisplay(dayId: dayId)],
          ),
        ),
      ),
    );
  }
}
