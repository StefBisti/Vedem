import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vedem/core/style/app_colors.dart';
import 'package:vedem/features/tasks/presentation/bloc/tasks_bloc.dart';
import 'package:vedem/features/tasks/presentation/public/update_task_display.dart';

class UpdateTaskPage extends StatelessWidget {
  final int taskId;
  final String previousContent;
  final int previouslySelectedCategoryIndex;
  final bool previouslyIsRecurring;
  final int previousDiamonds;
  final TasksBloc bloc;

  const UpdateTaskPage({
    super.key,
    required this.taskId,
    required this.bloc,
    required this.previousContent,
    required this.previouslySelectedCategoryIndex,
    required this.previouslyIsRecurring,
    required this.previousDiamonds,
  });

  static void route(
    BuildContext context,
    TasksBloc bloc,
    int taskId,
    String previousContent,
    int previouslySelectedCategoryIndex,
    bool previouslyIsRecurring,
    int previousDiamonds,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => UpdateTaskPage(
          taskId: taskId,
          previousContent: previousContent,
          previousDiamonds: previousDiamonds,
          previouslyIsRecurring: previouslyIsRecurring,
          previouslySelectedCategoryIndex: previouslySelectedCategoryIndex,
          bloc: bloc,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: bloc,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 0.0,
          scrolledUnderElevation: 0.0,
          elevation: 0.0,
          backgroundColor: AppColors.darkBackgroundColor.withAlpha(0),
        ),
        backgroundColor: AppColors.darkBackgroundColor,
        extendBodyBehindAppBar: true,
        body: UpdateTaskDisplay(
          taskId: taskId,
          previousContent: previousContent,
          previousDiamonds: previousDiamonds,
          previouslyIsRecurring: previouslyIsRecurring,
          previouslySelectedCategoryIndex: previouslySelectedCategoryIndex,
        ),
      ),
    );
  }
}
