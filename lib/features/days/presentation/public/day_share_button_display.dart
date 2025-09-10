import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vedem/core/style/app_colors.dart';
import 'package:vedem/features/days/presentation/cubit/days_cubit.dart';

class DayShareButtonDisplay extends StatelessWidget {
  final String dayId;

  const DayShareButtonDisplay({super.key, required this.dayId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DaysCubit, DaysState>(
      builder: (context, state) {
        int dayIndexInState = state.days.indexWhere((d) => d.dayId == dayId);
        if(dayIndexInState == -1) return SizedBox();
        
        return FloatingActionButton(
          heroTag: 'share',
          mini: true,
          backgroundColor: AppColors.lightBackgroundColor,
          foregroundColor: AppColors.primaryDarkTextColor,
          shape: CircleBorder(),
          child: Transform.translate(
            offset: Offset(-1, 0),
            child: Icon(
              Icons.share_rounded,
              color: AppColors.primaryDarkTextColor,
              size: 24.0,
            ),
          ),
          onPressed: () {
            context.read<DaysCubit>().shareDay(dayIndexInState);
          },
        );
      },
    );
  }
}
