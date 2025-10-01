import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vedem/core/pages/choose_from_existing_tasks_page.dart';
import 'package:vedem/core/style/app_colors.dart';
import 'package:vedem/core/style/app_style.dart';
import 'package:vedem/core/style/app_text_styles.dart';
import 'package:vedem/features/tasks/presentation/cubit/tasks_cubit.dart';
import 'package:vedem/features/tasks/presentation/private/create_update_task/daily_task_section.dart';
import 'package:vedem/features/tasks/presentation/private/create_update_task/more_options_section.dart';
import 'package:vedem/features/tasks/presentation/private/create_update_task/rewarded_task_section.dart';
import 'package:vedem/features/tasks/presentation/private/create_update_task/task_decision_buttons.dart';
import 'package:vedem/features/tasks/presentation/private/create_update_task/task_input_all.dart';
import 'package:vedem/features/tasks/presentation/private/create_update_task/task_category_selector.dart';
import 'package:vedem/features/tasks/presentation/private/create_update_task/task_gradient.dart';

class CreateTaskDisplay extends StatefulWidget {
  final String dayId;

  const CreateTaskDisplay({super.key, required this.dayId});

  @override
  State<CreateTaskDisplay> createState() => _CreateTaskDisplayState();
}

class _CreateTaskDisplayState extends State<CreateTaskDisplay> {
  int selectedCategoryIndex = -1;
  late ScrollController scrollController;
  late TextEditingController contentController;
  late FocusNode contentFocus;
  final Map<int, TextEditingController> subtasksControllers = {};
  final Map<int, FocusNode> subtasksListenersFocusNodes = {};
  final Map<int, FocusNode> subtasksTextFocusNodes = {};
  final List<int> subtasksKeys = [];
  int nextKeyToUse = 0;

  bool isStarred = false;
  bool isRewardedTask = false;
  bool isDailyTask = false;
  bool isMoreOptionsActive = false;
  bool isDueTimeActive = false;
  bool isNotifyTimeActive = false;

  int? effortRequired;
  int? taskImportance;
  int? timeRequired;
  int? taskDiamonds;
  int dueTime = 0;
  int notifyTime = 0;
  late String addToDate;
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
    addToDate = widget.dayId;
    scrollController = ScrollController();
    contentController = TextEditingController()
      ..addListener(
        () => setState(() {
          formError = null;
        }),
      );
    contentFocus = FocusNode()..requestFocus();
  }

  @override
  void dispose() {
    scrollController.dispose();
    contentFocus.dispose();
    contentController.dispose();
    for (TextEditingController c in subtasksControllers.values) {
      c.dispose();
    }
    for (FocusNode f in subtasksListenersFocusNodes.values) {
      f.dispose();
    }
    for (FocusNode f in subtasksTextFocusNodes.values) {
      f.dispose();
    }
    super.dispose();
  }

  int? _computeDiamonds(int? minutes, int? effort, int? importance) {
    if (minutes == null || effort == null || importance == null) return null;

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
    for (TextEditingController subtask in subtasksControllers.values) {
      if (subtask.text.trim().isEmpty) {
        return 'All subtasks must not be empty';
      }
    }
    if (isRewardedTask) {
      if (effortRequired == null) {
        return 'Input how much effort the task will take';
      }
      if (taskImportance == null) {
        return 'Input how important the task is';
      }
      if (timeRequired == null || timeRequired == 0) {
        return 'Input how much time the task will take';
      }
    }

    return null;
  }

  void _handleAddSubtask() {
    int newKey = nextKeyToUse++;
    subtasksControllers[newKey] = TextEditingController()
      ..addListener(() {
        _handleOnSubtaskTextChanged(newKey);
        setState(() {
          formError = null;
        });
      });
    subtasksListenersFocusNodes[newKey] = FocusNode();
    subtasksTextFocusNodes[newKey] = FocusNode()..requestFocus();
    subtasksKeys.add(newKey);
    setState(() {
      formError = null;
    });
  }

  void _handleOnSubtaskTextChanged(int subtaskKey) {
    int index = subtasksKeys.indexOf(subtaskKey);

    final String text = subtasksControllers[subtaskKey]!.text;
    if (text.contains('\n')) {
      final int newLineIndex = text.indexOf('\n');
      final String otherText = text.substring(0, newLineIndex);
      final String thisText = text.substring(newLineIndex + 1, text.length);

      subtasksControllers[subtaskKey]!.text = thisText;
      subtasksControllers[subtaskKey]!.selection = TextSelection.collapsed(
        offset: 0,
      );
      int newKey = nextKeyToUse++;
      subtasksControllers[newKey] = TextEditingController(text: otherText)
        ..addListener(() => _handleOnSubtaskTextChanged(newKey));
      subtasksListenersFocusNodes[newKey] = FocusNode();
      subtasksTextFocusNodes[newKey] = FocusNode();
      subtasksKeys.insert(index, newKey);
      setState(() {
        formError = null;
      });
    } else {
      if (formError != null) {
        setState(() {
          formError = null;
        });
      }
    }
  }

  void _handleOnKeyPressed(int subtaskKey, KeyEvent key) {
    int index = subtasksKeys.indexOf(subtaskKey);
    if (key is KeyDownEvent &&
        key.logicalKey == LogicalKeyboardKey.backspace &&
        subtasksControllers[subtaskKey]!.selection.baseOffset == 0) {
      if (subtasksControllers[subtaskKey]!.text.isEmpty) {
        subtasksControllers.remove(subtaskKey);
        subtasksListenersFocusNodes.remove(subtaskKey);
        subtasksTextFocusNodes.remove(subtaskKey);
        subtasksKeys.remove(subtaskKey);
        if (index > 0) {
          subtasksTextFocusNodes[subtasksKeys[index - 1]]!.requestFocus();
        }
        setState(() {
          formError = null;
        });
      } else if (index > 0) {
        String newText =
            subtasksControllers[subtasksKeys[index - 1]]!.text +
            subtasksControllers[subtaskKey]!.text;
        subtasksControllers[subtasksKeys[index - 1]]!.value = TextEditingValue(
          selection: TextSelection.collapsed(
            offset: subtasksControllers[subtasksKeys[index - 1]]!.text.length,
          ),
          text: newText,
        );
        subtasksControllers.remove(subtaskKey);
        subtasksListenersFocusNodes.remove(subtaskKey);
        subtasksTextFocusNodes.remove(subtaskKey);
        subtasksKeys.remove(subtaskKey);
        subtasksTextFocusNodes[subtasksKeys[index - 1]]!.requestFocus();
        setState(() {
          formError = null;
        });
      }
    }
  }

  void _handleOnReorder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final int key = subtasksKeys.removeAt(oldIndex);
    subtasksKeys.insert(newIndex, key);
    setState(() {
      formError = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          top: 0.0,
          left: 0.0,
          right: 0.0,
          height: 400.0,
          child: TaskGradient(
            color: selectedCategoryIndex != -1
                ? colors[selectedCategoryIndex]
                : AppColors.darkBackgroundColor,
          ),
        ),

        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppStyle.pageHorizontalPadding,
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // CATEGORY SELECTOR
                  const SizedBox(height: 16.0),
                  TaskCategorySelector(
                    categoriesNames: categories,
                    categoriesColors: colors,
                    categoriesIcons: icons,
                    selectedCategoryIndex: selectedCategoryIndex,
                    onSelected: (v) {
                      if (v != selectedCategoryIndex) {
                        FocusManager.instance.primaryFocus?.unfocus();
                        setState(() {
                          selectedCategoryIndex = v;
                          formError = null;
                        });
                      }
                    },
                  ),

                  // TASK INPUT, SUBTASKS, CONTROL BUTTONS
                  TaskInputAll(
                    contentController: contentController,
                    contentFocus: contentFocus,
                    subtasksControllers: subtasksControllers,
                    subtasksListenersFocusNodes: subtasksListenersFocusNodes,
                    subtasksTextFocusNodes: subtasksTextFocusNodes,
                    subtasksKeys: subtasksKeys,
                    color: selectedCategoryIndex != -1
                        ? colors[selectedCategoryIndex]
                        : AppColors.primaryLightTextColor,
                    isStarred: isStarred,
                    onAddSubtaskPressed: _handleAddSubtask,
                    onStarredPressed: () {
                      FocusManager.instance.primaryFocus?.unfocus();
                      setState(() {
                        isStarred = !isStarred;
                      });
                    },
                    onReorder: _handleOnReorder,
                    onKeyPressed: _handleOnKeyPressed,
                  ),

                  // DAILY TASK SECTION
                  DailyTaskSection(
                    isDailyTask: isDailyTask,
                    onSwitched: () {
                      FocusManager.instance.primaryFocus?.unfocus();
                      setState(() {
                        isDailyTask = !isDailyTask;
                      });
                    },
                  ),

                  // REWARDED TASK SECTION
                  RewardedTaskSection(
                    isRewardedTask: isRewardedTask,
                    onSwitched: () {
                      FocusManager.instance.primaryFocus?.unfocus();
                      setState(() => isRewardedTask = !isRewardedTask);
                    },
                    effort: effortRequired,
                    importance: taskImportance,
                    time: timeRequired,
                    diamonds: taskDiamonds,
                    onEffortChanged: (e) {
                      if (e != effortRequired) {
                        FocusManager.instance.primaryFocus?.unfocus();
                        setState(() {
                          effortRequired = e;
                          taskDiamonds = _computeDiamonds(
                            timeRequired,
                            effortRequired,
                            taskImportance,
                          );
                          formError = null;
                        });
                      }
                    },
                    onImportanceChanged: (imp) {
                      if (imp != taskImportance) {
                        FocusManager.instance.primaryFocus?.unfocus();
                        setState(() {
                          taskImportance = imp;
                          taskDiamonds = _computeDiamonds(
                            timeRequired,
                            effortRequired,
                            taskImportance,
                          );
                          formError = null;
                        });
                      }
                    },
                    onTimeChanged: (m) {
                      if (m != timeRequired) {
                        FocusManager.instance.primaryFocus?.unfocus();
                        setState(() {
                          timeRequired = m;
                          taskDiamonds = _computeDiamonds(
                            timeRequired,
                            effortRequired,
                            taskImportance,
                          );
                          formError = null;
                        });
                      }
                    },
                  ),

                  // MORE OPTIONS SECTION
                  MoreOptionsSection(
                    isMoreOptionsActive: isMoreOptionsActive,
                    isDueTimeActive: isDueTimeActive,
                    isNotifyTimeActive: isNotifyTimeActive,
                    dueTime: dueTime,
                    notifyTime: notifyTime,
                    addToDate: addToDate,
                    onMoreOptionsSwitched: () {
                      FocusManager.instance.primaryFocus?.unfocus();
                      setState(() {
                        isMoreOptionsActive = !isMoreOptionsActive;
                        formError = null;
                      });
                    },
                    onDueTimeSwitched: () {
                      FocusManager.instance.primaryFocus?.unfocus();
                      setState(() {
                        isDueTimeActive = !isDueTimeActive;
                        formError = null;
                      });
                    },
                    onNotifyTimeSwitched: () {
                      FocusManager.instance.primaryFocus?.unfocus();
                      setState(() {
                        isNotifyTimeActive = !isNotifyTimeActive;
                        formError = null;
                      });
                    },
                    onDueTimeChanged: (m) {
                      FocusManager.instance.primaryFocus?.unfocus();
                      setState(() {
                        dueTime = m;
                        formError = null;
                      });
                    },
                    onNotifyTimeChanged: (m) {
                      FocusManager.instance.primaryFocus?.unfocus();
                      setState(() {
                        notifyTime = m;
                        formError = null;
                      });
                    },
                    onAddToDateChanged: (d) {
                      FocusManager.instance.primaryFocus?.unfocus();
                      setState(() {
                        addToDate = d;
                        formError = null;
                      });
                    },
                  ),

                  // DECISION BUTTONS
                  SizedBox(height: 16.0),
                  TaskDecisionButtons(
                    enabled: _validate() == null,
                    decisionButtonText: 'Create',
                    decisionButtonIcon: Icons.add_rounded,
                    onDecisionButtonPressed: () {
                      String? error = _validate();
                      if (error == null) {
                        context.read<TasksCubit>().addNewTask(
                          dayId: addToDate,
                          categoryId: selectedCategoryIndex,
                          content: contentController.text,
                          subtasks: [], // TODO
                          isStarred: isStarred,
                          isDailyTask: isDailyTask,
                          isRewardedTask: isRewardedTask,
                          effortRequired: effortRequired,
                          taskImportance: taskImportance,
                          timeRequired: timeRequired,
                          taskDiamonds: taskDiamonds,
                          isDueTimeActive: isDueTimeActive,
                          dueTime: dueTime,
                          isNotifyTimeActive: isNotifyTimeActive,
                          notifyTime: notifyTime,
                        );
                        Navigator.pop(context);
                      } else {
                        setState(() {
                          formError = error;
                        });
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          scrollController.animateTo(
                            scrollController.position.maxScrollExtent,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          );
                        });
                      }
                    },
                    onCancelButtonPressed: () {
                      Navigator.pop(context);
                    },
                  ),

                  // CHOOSE FROM OTHER TASKS
                  SizedBox(
                    height: 40.0, // 24.0 + 16.0
                    child: GestureDetector(
                      onTap: () {
                        ChooseFromExistingTasksPage.route(context);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'Choose from existing tasks',
                            style: AppTextStyles.content.copyWith(
                              color: AppColors.primaryLightTextColor,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                              decorationColor: AppColors.primaryLightTextColor,
                              decorationThickness: 1.0,
                            ),
                          ),
                          SizedBox(
                            width: 18.0,
                            child: Icon(
                              Icons.keyboard_arrow_right_rounded,
                              color: AppColors.primaryLightTextColor,
                              size: 20.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ERROR
                  if (formError != null) ...[
                    const SizedBox(height: 16.0),
                    Row(
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
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
