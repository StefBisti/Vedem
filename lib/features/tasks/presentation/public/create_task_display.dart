import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vedem/core/style/app_colors.dart';
import 'package:vedem/core/style/app_text_styles.dart';
import 'package:vedem/core/utils/time_utils.dart';
import 'package:vedem/features/tasks/presentation/bloc/tasks_bloc.dart';
import 'package:vedem/features/tasks/presentation/private/create_update_task/create_task_level_selector.dart';
import 'package:vedem/features/tasks/presentation/private/create_update_task/create_task_text_field.dart';
import 'package:vedem/features/tasks/presentation/private/create_update_task/create_task_category_selector.dart';
import 'package:vedem/features/tasks/presentation/private/create_update_task/create_task_decision_buttons.dart';
import 'package:vedem/features/tasks/presentation/private/create_update_task/create_task_gradient.dart';
import 'package:vedem/features/tasks/presentation/private/create_update_task/create_task_recurring.dart';
import 'package:vedem/features/tasks/presentation/private/create_update_task/create_task_stepper.dart';
import 'package:vedem/features/tasks/presentation/private/create_update_task/create_task_title.dart';

class CreateTaskDisplay extends StatefulWidget {
  final String dayId;

  const CreateTaskDisplay({super.key, required this.dayId});

  @override
  State<CreateTaskDisplay> createState() => _CreateTaskDisplayState();
}

class _CreateTaskDisplayState extends State<CreateTaskDisplay> {
  int selectedCategoryIndex = -1;
  late TextEditingController contentController;
  late FocusNode contentFocus;
  bool isRecurring = false;
  int minutes = 0, effort = -1, importance = -1, diamonds = 0;
  String? formError;
  int beforeAnimStart = 0, inBetweenAnims = 200;

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
    contentFocus = FocusNode();
    contentFocus.addListener(() {
      if (contentFocus.hasFocus == false) {
        setState(() {});
      }
    });
    contentController = TextEditingController();
    contentController.addListener(
      () => setState(() {
        formError = null;
      }),
    );
  }

  @override
  void dispose() {
    contentFocus.dispose();
    contentController.dispose();
    super.dispose();
  }

  int _calculateDiamondsFromMinutes(int minutes, int effort, int importance) {
    final int baseRatePerHour = 10;
    final double fatigueStartHours = 4.0;
    final double fatigueFactorPerHour = 0.1;

    if (minutes == 0 || effort == -1 || importance == -1) return 0;

    final double hours = minutes / 60.0;

    // effort multiplier: 0 -> 0.8, 1 -> 0.9, 2 -> 1.0, 3 -> 1.1, 4 -> 1.2
    final double effortMultiplier = 0.8 + effort * 0.1;

    // importance multiplier: 0 -> 0.6, 1 -> 0.8, 2 -> 1.0, 3 -> 1.2, 4 -> 1.4
    final double importanceMultiplier = 0.6 + importance * 0.2;

    double diamonds =
        baseRatePerHour * hours * effortMultiplier * importanceMultiplier;

    if (hours > fatigueStartHours) {
      final double extra = hours - fatigueStartHours;
      final double discount = (extra * fatigueFactorPerHour).clamp(0.0, 0.6);
      diamonds = diamonds * (1.0 - discount);
    }

    return max(1, diamonds.round());
  }

  String? _validate() {
    if (selectedCategoryIndex == -1) {
      return 'You need to select a category';
    }
    if (contentController.text.trim().isEmpty) {
      return 'Task content must not be empty';
    }
    if (effort == -1) {
      return 'Input how much effort the task will take';
    }
    if (importance == -1) {
      return 'Input how important the task is';
    }
    if (minutes == 0) {
      return 'Input how much time the task will take';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    diamonds = _calculateDiamondsFromMinutes(minutes, effort, importance);
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
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // CATEGORY SELECTOR
                  const SizedBox(height: 32.0),
                  CreateTaskTitle(
                        icon: null,
                        text: 'Choose a category',
                        hidden: selectedCategoryIndex != -1,
                      )
                      .animate(
                        delay: Duration(
                          milliseconds: beforeAnimStart + 0 * inBetweenAnims,
                        ),
                      )
                      .fadeIn()
                      .slideY(),
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
                      )
                      .animate(
                        delay: Duration(
                          milliseconds: beforeAnimStart + 0 * inBetweenAnims,
                        ),
                      )
                      .fadeIn()
                      .slideY(),

                  // INPUT
                  const SizedBox(height: 32.0),
                  CreateTaskTitle(
                        icon: null, //Icons.check_rounded,
                        text: 'What will you do',
                        hidden:
                            effort != -1 &&
                            contentController.text.trim().isNotEmpty &&
                            !contentFocus.hasFocus,
                      )
                      .animate(
                        delay: Duration(
                          milliseconds: beforeAnimStart + 1 * inBetweenAnims,
                        ),
                      )
                      .fadeIn()
                      .slideY(),
                  const SizedBox(height: 8.0),
                  CreateTaskTextField(
                        controller: contentController,
                        contentFocus: contentFocus,
                        color: selectedCategoryIndex != -1
                            ? colors[selectedCategoryIndex]
                            : AppColors.primaryLightTextColor,
                      )
                      .animate(
                        delay: Duration(
                          milliseconds: beforeAnimStart + 1 * inBetweenAnims,
                        ),
                      )
                      .fadeIn()
                      .slideY(),
                  const SizedBox(height: 4.0),
                  CreateTaskRecurring(
                        isRecurring: isRecurring,
                        hidden: effort != -1,
                        onChanged: (v) {
                          setState(() {
                            isRecurring = v;
                            formError = null;
                          });
                        },
                      )
                      .animate(
                        delay: Duration(
                          milliseconds: beforeAnimStart + 1 * inBetweenAnims,
                        ),
                      )
                      .fadeIn()
                      .slideY(),

                  // EFFORT
                  const SizedBox(height: 32.0),
                  CreateTaskTitle(
                        icon: null,
                        text: 'How much effort will it take',
                        hidden: effort != -1,
                      )
                      .animate(
                        delay: Duration(
                          milliseconds: beforeAnimStart + 2 * inBetweenAnims,
                        ),
                      )
                      .fadeIn()
                      .slideY(),
                  const SizedBox(height: 8.0),
                  CreateTaskLevelSelector(
                        colors: [
                          Colors.green,
                          Colors.lightGreen,
                          Colors.amber,
                          Colors.orange,
                          Colors.red,
                        ],
                        labels: ['Easy', 'Light', 'Medium', 'Hard', 'Brutal'],
                        icons: [
                          Icons.self_improvement,
                          Icons.directions_walk,
                          Icons.directions_run,
                          Icons.bolt,
                          Icons.whatshot,
                        ],
                        selectedLevel: effort,
                        onSelected: (e) {
                          if (e != effort) {
                            setState(() {
                              effort = e;
                              formError = null;
                            });
                          }
                        },
                      )
                      .animate(
                        delay: Duration(
                          milliseconds: beforeAnimStart + 2 * inBetweenAnims,
                        ),
                      )
                      .fadeIn()
                      .slideY(),

                  // IMPORTANCE
                  const SizedBox(height: 16.0),
                  CreateTaskTitle(
                        icon: null,
                        text: 'How important it is',
                        hidden: importance != -1,
                      )
                      .animate(
                        delay: Duration(
                          milliseconds: beforeAnimStart + 3 * inBetweenAnims,
                        ),
                      )
                      .fadeIn()
                      .slideY(),
                  const SizedBox(height: 8.0),
                  CreateTaskLevelSelector(
                        colors: [
                          Colors.cyan,
                          Colors.blue,
                          Colors.amber,
                          Colors.orange,
                          Colors.red,
                        ],
                        labels: [
                          'Trivial',
                          'Minor',
                          'Normal',
                          'Major',
                          'Urgent',
                        ],
                        icons: [
                          Icons.low_priority,
                          Icons.bookmark_border,
                          Icons.label_important,
                          Icons.priority_high,
                          Icons.error,
                        ],
                        selectedLevel: importance,
                        onSelected: (imp) {
                          if (imp != importance) {
                            setState(() {
                              importance = imp;
                              formError = null;
                            });
                          }
                        },
                      )
                      .animate(
                        delay: Duration(
                          milliseconds: beforeAnimStart + 3 * inBetweenAnims,
                        ),
                      )
                      .fadeIn()
                      .slideY(),

                  // TIME
                  const SizedBox(height: 16.0),
                  CreateTaskTitle(
                        icon: null, //Icons.schedule,
                        text: 'How much time will it take',
                      )
                      .animate(
                        delay: Duration(
                          milliseconds: beforeAnimStart + 4 * inBetweenAnims,
                        ),
                      )
                      .fadeIn()
                      .slideY(),
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
                      )
                      .animate(
                        delay: Duration(
                          milliseconds: beforeAnimStart + 4 * inBetweenAnims,
                        ),
                      )
                      .fadeIn()
                      .slideY(),

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
                      )
                      .animate(
                        delay: Duration(
                          milliseconds: beforeAnimStart + 5 * inBetweenAnims,
                        ),
                      )
                      .fadeIn()
                      .slideY(),

                  // CANCEL OR CREATE
                  const SizedBox(height: 8.0),
                  CreateTaskDecisionButtons(
                        createText: 'Create',
                        createIcon: Icons.add_rounded,
                        createHidden:
                            selectedCategoryIndex == -1 ||
                            contentController.text.trim().isEmpty ||
                            effort == -1 ||
                            importance == -1 ||
                            minutes == 0,
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
                      )
                      .animate(
                        delay: Duration(
                          milliseconds: beforeAnimStart + 5 * inBetweenAnims,
                        ),
                      )
                      .fadeIn()
                      .slideY(),

                  if (formError != null) ...[
                    const SizedBox(height: 8.0),
                    Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 20.0,
                        ),
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
                  const SizedBox(height: 32.0),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
