import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vedem/core/style/app_colors.dart';
import 'package:vedem/core/style/app_text_styles.dart';
import 'package:vedem/core/utils/time_utils.dart';
import 'package:vedem/features/days/domain/entities/day_entity.dart';
import 'package:vedem/features/days/presentation/cubit/days_cubit.dart';

class DayHeaderDisplay extends StatelessWidget {
  final String dayId;

  const DayHeaderDisplay({super.key, required this.dayId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DaysCubit, DaysState>(
      builder: (context, state) {
        int dayIndexInState = state.days.indexWhere((d) => d.dayId == dayId);
        if (dayIndexInState == -1) return SizedBox();

        DayEntity day = state.days[dayIndexInState];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    TimeUtils.formatDayId(dayId, addYear: true),
                    style: AppTextStyles.heading,
                  ),
                  Row(
                    children: [
                      Text('${day.diamonds} ', style: AppTextStyles.heading),
                      Icon(
                        Icons.diamond_rounded,
                        size: 18.0,
                        color: AppColors.primaryDarkTextColor,
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 8.0),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "Only 38 more ",
                      style: AppTextStyles.content,
                    ),
                    WidgetSpan(
                      child: Icon(
                        Icons.diamond_rounded,
                        color: AppColors.secondaryDarkTextColor,
                        size: 14.0,
                      ),
                      alignment: PlaceholderAlignment.middle,
                    ),
                    TextSpan(
                      text: " to achieve today's goal",
                      style: AppTextStyles.content,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
