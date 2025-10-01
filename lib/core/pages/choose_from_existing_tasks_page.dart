import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:vedem/core/style/app_colors.dart';
import 'package:vedem/features/tasks/presentation/cubit/tasks_cubit.dart';
import 'package:vedem/features/tasks/presentation/public/browse_tasks_display.dart';

class ChooseFromExistingTasksPage extends StatelessWidget {
  const ChooseFromExistingTasksPage({super.key});

  static void route(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ChooseFromExistingTasksPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider(create: (_) => GetIt.instance<TasksCubit>())],
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          scrolledUnderElevation: 0.0,
          elevation: 0.0,
          toolbarHeight: 0.0,
          backgroundColor: AppColors.darkBackgroundColor.withAlpha(100),
        ),
        backgroundColor: AppColors.darkBackgroundColor,
        extendBodyBehindAppBar: false,
        body: SingleChildScrollView(child: BrowseTasksDisplay()),
      ),
    );
  }
}
