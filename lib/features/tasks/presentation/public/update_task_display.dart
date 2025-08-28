import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vedem/core/style/app_colors.dart';
import 'package:vedem/core/style/app_text_styles.dart';
import 'package:vedem/features/tasks/presentation/bloc/tasks_bloc.dart';
import 'package:vedem/features/tasks/presentation/private/create_update_task/create_task_text_field.dart';
import 'package:vedem/features/tasks/presentation/private/create_update_task/create_task_category_selector.dart';
import 'package:vedem/features/tasks/presentation/private/create_update_task/create_task_decision_buttons.dart';
import 'package:vedem/features/tasks/presentation/private/create_update_task/create_task_gradient.dart';
import 'package:vedem/features/tasks/presentation/private/create_update_task/create_task_recurring.dart';
import 'package:vedem/features/tasks/presentation/private/create_update_task/create_task_title.dart';

class UpdateTaskDisplay extends StatefulWidget {
  final int taskId;
  final int previouslySelectedCategoryIndex;
  final bool previouslyIsRecurring;
  final String previousContent;
  final int previousDiamonds;

  const UpdateTaskDisplay({
    super.key,
    required this.taskId,
    required this.previouslySelectedCategoryIndex,
    required this.previouslyIsRecurring,
    required this.previousContent,
    required this.previousDiamonds,
  });

  @override
  State<UpdateTaskDisplay> createState() => _UpdateTaskDisplayState();
}

class _UpdateTaskDisplayState extends State<UpdateTaskDisplay> {
  late TextEditingController contentController;
  late FocusNode contentFocus;
  late int selectedCategoryIndex;
  late bool isRecurring;

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
    contentController = TextEditingController(text: widget.previousContent);
    contentController.addListener(
      () => setState(() {
        formError = null;
      }),
    );

    selectedCategoryIndex = widget.previouslySelectedCategoryIndex;
    isRecurring = widget.previouslyIsRecurring;
  }

  @override
  void dispose() {
    contentFocus.dispose();
    contentController.dispose();
    super.dispose();
  }

  String? _validate() {
    if (selectedCategoryIndex == -1) {
      return 'You need to select a category';
    }
    if (contentController.text.trim().isEmpty) {
      return 'Task content must not be empty';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
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
                  CreateTaskTitle(icon: null, text: 'Choose a category')
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
                  CreateTaskTitle(icon: null, text: 'What will you do')
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
                        hidden: false,
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

                  // CANCEL OR CREATE
                  const SizedBox(height: 8.0),
                  CreateTaskDecisionButtons(
                        createText: 'Update',
                        createIcon: Icons.edit,
                        createHidden:
                            selectedCategoryIndex == -1 ||
                            contentController.text.trim().isEmpty,
                        onAccept: () {
                          final String? res = _validate();
                          if (res == null) {
                            context.read<TasksBloc>().add(
                              UpdateTaskEvent(
                                taskId: widget.taskId,
                                newCategoryId: selectedCategoryIndex,
                                newContent: contentController.text,
                                newIsRecurring: isRecurring,
                                newDiamonds: widget.previousDiamonds,
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
                          milliseconds: beforeAnimStart + 2 * inBetweenAnims,
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
