import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vedem/core/style/app_colors.dart';
import 'package:vedem/core/style/app_text_styles.dart';
import 'package:vedem/core/utils/time_utils.dart';
import 'package:vedem/features/tasks/presentation/bloc/tasks_bloc.dart';
import 'package:vedem/features/tasks/presentation/private/create_task/create_task_text_field.dart';
import 'package:vedem/features/tasks/presentation/private/create_task/create_task_category_selector.dart';
import 'package:vedem/features/tasks/presentation/private/create_task/create_task_decision_buttons.dart';
import 'package:vedem/features/tasks/presentation/private/create_task/create_task_gradient.dart';
import 'package:vedem/features/tasks/presentation/private/create_task/create_task_recurring.dart';
import 'package:vedem/features/tasks/presentation/private/create_task/create_task_stepper.dart';
import 'package:vedem/features/tasks/presentation/private/create_task/create_task_title.dart';

class CreateTaskDisplay extends StatefulWidget {
  final String dayId;

  const CreateTaskDisplay({super.key, required this.dayId});

  @override
  State<CreateTaskDisplay> createState() => _CreateTaskDisplayState();
}

class _CreateTaskDisplayState extends State<CreateTaskDisplay> {
  int selectedCategoryIndex = -1;
  late TextEditingController contentController;
  bool isRecurring = false;
  int minutes = 0;
  int effort = 0;
  int diamonds = 0;
  String? formError;

  ////////////////////// temp //////////////////////
  final List<String> categories = const [
    'Wellbeing',
    'Money',
    'Personality',
    'Academic',
  ];

  final List<IconData> icons = const [
    Icons.self_improvement,
    Icons.attach_money,
    Icons.psychology,
    Icons.school,
  ];

  final List<Color> colors = const [
    Colors.green,
    Colors.blue,
    Colors.red,
    Colors.amber,
  ];
  ////////////////////// temp //////////////////////

  @override
  void initState() {
    super.initState();
    contentController = TextEditingController();
    contentController.addListener(
      () => setState(() {
        formError = null;
      }),
    );
  }

  @override
  void dispose() {
    contentController.dispose();
    super.dispose();
  }

  int _calculateDiamondsFromMinutes(int minutes, int effort) {
    if (minutes == 0 || effort == 0) return 0;

    const int baseRatePerHour = 10;
    const double fatigueStartHours = 4.0;
    const double fatigueFactorPerHour = 0.05;

    final double hours = minutes / 60.0;
    final double effortMultiplier = 0.6 + (effort - 1) * 0.1;

    double diamonds = baseRatePerHour * hours * effortMultiplier;

    if (hours > fatigueStartHours) {
      final double extra = hours - fatigueStartHours;
      final double discount = (extra * fatigueFactorPerHour).clamp(0.0, 0.6);
      diamonds = diamonds * (1.0 - discount);
    }

    return diamonds.ceil();
  }

  String? _validate() {
    if (selectedCategoryIndex == -1) {
      return 'You need to select a category';
    }
    if (contentController.text.trim().isEmpty) {
      return 'Task content must not be empty';
    }
    if (minutes == 0) {
      return 'Input how much time the task will take';
    }
    if (effort == 0) {
      return 'Input how much effort the task will take';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    diamonds = _calculateDiamondsFromMinutes(minutes, effort);
    return Stack(
      children: [
        Positioned.fill(
          child: CreateTaskGradient(
            color: selectedCategoryIndex != -1
                ? colors[selectedCategoryIndex]
                : AppColors.darkBackgroundColor,
          ),
        ),

        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // CATEGORY
                const SizedBox(height: 32.0),
                CreateTaskTitle(icon: null, text: 'Choose a category'),
                const SizedBox(height: 8.0),
                CreateTaskCategorySelector(
                  categoriesNames: categories,
                  categoriesColors: colors,
                  categoriesIcons: icons,
                  selectedCategoryIndex: selectedCategoryIndex,
                  onSelected: (v) {
                    if (v != selectedCategoryIndex) {
                      setState(() {
                        selectedCategoryIndex = v;
                        formError = null;
                      });
                    }
                  },
                ),

                // INPUT
                const SizedBox(height: 32.0),
                CreateTaskTitle(
                  icon: Icons.check_rounded,
                  text: 'What will you do',
                ),
                const SizedBox(height: 8.0),
                CreateTaskTextField(
                  controller: contentController,
                  color: selectedCategoryIndex != -1
                      ? colors[selectedCategoryIndex]
                      : AppColors.primaryLightTextColor,
                ),
                const SizedBox(height: 8.0),
                CreateTaskRecurring(
                  onChanged: (v) {
                    isRecurring = v!;
                  },
                ),

                // TIME
                const SizedBox(height: 32.0),
                CreateTaskTitle(
                  icon: Icons.schedule,
                  text: 'How much time will it take',
                ),
                const SizedBox(height: 8.0),
                CreateTaskStepper(
                  display: (m) => TimeUtils.minutesToString(m),
                  onChanged: (m) {
                    setState(() {
                      minutes = m;
                      formError = null;
                    });
                  },
                  min: 0,
                  max: 480,
                  steppers: [
                    0,
                    3,
                    5,
                    6,
                    6,
                    for (int i = 5; i < 10; i++) 10,
                    for (int i = 10; i < 20; i++) 13,
                    100000,
                  ],
                ),

                // EFFORT
                const SizedBox(height: 16.0),
                CreateTaskTitle(
                  icon: Icons.bolt,
                  text: 'How much effort will it take',
                ),
                const SizedBox(height: 8.0),
                CreateTaskStepper(
                  display: (e) => '$e / 10',
                  onChanged: (e) {
                    setState(() {
                      effort = e;
                      formError = null;
                    });
                  },
                  min: 0,
                  max: 10,
                  steppers: [0, 100],
                ),

                // RESULTS
                const SizedBox(height: 8.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'You will get $diamonds ',
                      style: AppTextStyles.content.copyWith(
                        color: AppColors.primaryLightTextColor,
                      ),
                    ),
                    Icon(
                      Icons.diamond_rounded,
                      color: AppColors.primaryLightTextColor,
                      size: 16.0,
                    ),
                  ],
                ),

                // CANCEL OR CREATE
                const SizedBox(height: 8.0),
                CreateTaskDecisionButtons(
                  onAccept: () {
                    final String? res = _validate();
                    if (res == null) {
                      context.read<TasksBloc>().add(
                        CreateNewTaskEvent(
                          dayId: widget.dayId,
                          categoryId: selectedCategoryIndex,
                          content: contentController.text,
                          isRecurring: isRecurring,
                          diamonds: diamonds,
                        ),
                      );
                      Navigator.of(context).pop();
                    } else {
                      setState(() {
                        formError = res;
                      });
                    }
                  },
                  onCancel: () {
                    Navigator.of(context).pop();
                  },
                ),

                const SizedBox(height: 8.0),
                if (formError != null)
                  Row(
                    children: [
                      Icon(Icons.error, color: Colors.red, size: 20.0),
                      SizedBox(width: 8.0),
                      Text(
                        '$formError',
                        style: AppTextStyles.content.copyWith(
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
