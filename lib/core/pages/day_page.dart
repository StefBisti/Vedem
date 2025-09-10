import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:vedem/core/style/app_colors.dart';
import 'package:vedem/features/days/presentation/public/day_heart_button_display.dart';
import 'package:vedem/features/days/presentation/public/day_share_button_display.dart';
import 'package:vedem/features/highlights/presentation/cubit/highlights_cubit.dart';
import 'package:vedem/features/highlights/presentation/public/highlight_header_display.dart';
import 'package:vedem/features/rich_inputs/presentation/cubit/rich_inputs_cubit.dart';
import 'package:vedem/features/rich_inputs/presentation/public/rich_input_display.dart';
import 'package:vedem/features/tasks/presentation/bloc/tasks_bloc.dart';
import 'package:vedem/features/tasks/presentation/public/day_tasks_display.dart';

class DayPage extends StatelessWidget {
  final String dayId;
  final HighlightsCubit highlightsCubit;

  const DayPage({
    super.key,
    required this.dayId,
    required this.highlightsCubit,
  });

  static void route(BuildContext context, String dayId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DayPage(
          dayId: dayId,
          highlightsCubit: context.read<HighlightsCubit>(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              GetIt.instance<TasksBloc>()
                ..add(ReadTasksForDayEvent(dayId: dayId)),
        ),
        BlocProvider(
          create: (_) =>
              GetIt.instance<RichInputsCubit>()..loadRichInput(dayId),
        ),
        BlocProvider.value(value: highlightsCubit),
      ],
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          scrolledUnderElevation: 0.0,
          elevation: 0.0,
          toolbarHeight: 0.0,
          backgroundColor: AppColors.darkBackgroundColor.withAlpha(100),
        ),
        extendBodyBehindAppBar: true,
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HighlightHeaderDisplay(
                dayId: dayId,
                shareWidget: DayShareButtonDisplay(),
                heartWidget: DayHeartButtonDisplay(),
              ),
              const SizedBox(height: 16.0),
              DayTasksDisplay(dayId: dayId),
              const SizedBox(height: 16.0),
              RichInputDisplay(richInputKey: dayId),
              const SizedBox(height: 32.0),
            ],
          ),
        ),
      ),
    );
  }
}
