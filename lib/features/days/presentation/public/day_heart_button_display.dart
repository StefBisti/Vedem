import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vedem/core/style/app_colors.dart';
import 'package:vedem/features/days/presentation/cubit/days_cubit.dart';

class DayHeartButtonDisplay extends StatelessWidget {
  final String dayId;

  const DayHeartButtonDisplay({
    super.key,
    required this.dayId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DaysCubit, DaysState>(
      builder: (context, state) {
        int dayIndexInState = state.days.indexWhere((d) => d.dayId == dayId);
        if(dayIndexInState == -1) return SizedBox();
        
        bool hearted = state.days[dayIndexInState].hearted;
        print(hearted);
        return FloatingActionButton(
          heroTag: 'heart',
          mini: true,
          backgroundColor: AppColors.lightBackgroundColor,
          foregroundColor: AppColors.primaryDarkTextColor,
          shape: CircleBorder(),
          child: Icon(
            hearted ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            color: hearted ? Colors.red : AppColors.primaryDarkTextColor,
            size: 24.0,
          ),
          onPressed: () {
            context.read<DaysCubit>().toggleHeartForDay(dayIndexInState);
          },
        );
      },
    );
  }
}
