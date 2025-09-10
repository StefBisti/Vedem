import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:vedem/core/style/app_colors.dart';
import 'package:vedem/core/style/app_text_styles.dart';
import 'package:vedem/features/days/presentation/cubit/days_cubit.dart';
import 'package:vedem/features/highlights/presentation/cubit/highlights_cubit.dart';
import 'package:vedem/features/highlights/presentation/public/highlights_carousel_display.dart';

class MonthPage extends StatelessWidget {
  static void route(BuildContext context, String monthId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MonthPage(monthId: monthId)),
    );
  }

  final String monthId;

  const MonthPage({super.key, required this.monthId});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              GetIt.instance<HighlightsCubit>()
                ..loadHighlightsForMonth(monthId),
        ),
        BlocProvider(
          create: (_) =>
              GetIt.instance<DaysCubit>()
                ..loadDaysForMonth(monthId),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('Month Page: $monthId', style: AppTextStyles.heading),
        ),
        backgroundColor: AppColors.lightBackgroundColor,
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [SizedBox(height: 100), HighlightsCarouselDisplay()],
          ),
        ),
      ),
    );
  }
}
