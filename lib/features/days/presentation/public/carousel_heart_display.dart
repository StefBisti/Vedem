import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vedem/core/style/app_colors.dart';
import 'package:vedem/features/days/presentation/cubit/days_cubit.dart';

class CarouselHeartDisplay extends StatelessWidget {
  final String dayId;

  const CarouselHeartDisplay({super.key, required this.dayId});

  @override
  Widget build(BuildContext context) {
    final daysCubit = context.read<DaysCubit?>();
    if (daysCubit == null) return const SizedBox.shrink();

    return BlocBuilder<DaysCubit, DaysState>(
      builder: (context, state) {
        int dayIndexInState = state.days.indexWhere((d) => d.dayId == dayId);
        if (dayIndexInState == -1) return SizedBox();

        bool hearted = state.days[dayIndexInState].hearted;
        if (hearted == false) return SizedBox();

        return GestureDetector(
          onTap: () =>
              context.read<DaysCubit>().toggleHeartForDay(dayIndexInState),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.lightBackgroundColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(51),
                  blurRadius: 6,
                  spreadRadius: 1,
                  offset: Offset(2, 2),
                ),
              ],
            ),
            child: Icon(Icons.favorite_rounded, color: Colors.red, size: 24.0),
          ),
        );
      },
    );
  }
}
