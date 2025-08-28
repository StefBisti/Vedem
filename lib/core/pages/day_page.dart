import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:vedem/core/style/app_text_styles.dart';
import 'package:vedem/features/tasks/presentation/bloc/tasks_bloc.dart';
import 'package:vedem/features/tasks/presentation/public/day_tasks_display.dart';

class DayPage extends StatelessWidget {
  static void route(BuildContext context, String dayId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DayPage(dayId: dayId)),
    );
  }

  final String dayId;

  const DayPage({super.key, required this.dayId});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              GetIt.instance<TasksBloc>()
                ..add(ReadTasksForDayEvent(dayId: dayId)),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('Day Page: $dayId', style: AppTextStyles.heading),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: double.infinity,
                height: 200.0,
                child: ColoredBox(color: Colors.red),
              ),
              const SizedBox(height: 16.0,),
              DayTasksDisplay(dayId: dayId),
            ],
          ),
        ),
      ),
    );
  }
}
