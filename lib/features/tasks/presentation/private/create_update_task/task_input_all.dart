import 'package:flutter/material.dart';
import 'package:vedem/core/style/app_colors.dart';
import 'package:vedem/core/style/app_style.dart';
import 'package:vedem/core/style/app_text_styles.dart';
import 'package:vedem/features/tasks/presentation/private/other/task_subtask_text_field.dart';

class TaskInputAll extends StatelessWidget {
  final TextEditingController contentController;
  final FocusNode contentFocus;
  final Map<int, TextEditingController> subtasksControllers;
  final Map<int, FocusNode> subtasksListenersFocusNodes;
  final Map<int, FocusNode> subtasksTextFocusNodes;
  final List<int> subtasksKeys;
  final Color color;
  final bool isStarred;
  final Function() onAddSubtaskPressed;
  final Function() onStarredPressed;
  final Function(int, int) onReorder;
  final Function(int, KeyEvent) onKeyPressed;

  const TaskInputAll({
    super.key,
    required this.contentController,
    required this.contentFocus,
    required this.subtasksControllers,
    required this.subtasksListenersFocusNodes,
    required this.subtasksTextFocusNodes,
    required this.subtasksKeys,
    required this.color,
    required this.isStarred,
    required this.onAddSubtaskPressed,
    required this.onStarredPressed,
    required this.onReorder,
    required this.onKeyPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // TASK INPUT
        TextSelectionTheme(
          data: TextSelectionThemeData(
            cursorColor: AppColors.primaryLightTextColor,
            selectionHandleColor: AppColors.primaryLightTextColor,
            selectionColor: color.withAlpha(64),
          ),
          child: TextField(
            controller: contentController,
            focusNode: contentFocus,
            cursorRadius: Radius.circular(4.0),
            style: AppTextStyles.heading.copyWith(color: color),
            maxLines: null,
            minLines: 1,
            keyboardType: TextInputType.text,
            textAlignVertical: TextAlignVertical.top,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              isCollapsed: true,
              contentPadding: EdgeInsets.only(left: 4.0, right: 4.0, top: 32.0),
              border: InputBorder.none,
              hintText: 'What will you do',
              hintStyle: AppTextStyles.heading.copyWith(
                color: AppColors.secondaryLightTextColor,
              ),
            ),
          ),
        ),

        // SUBTASKS
        if (subtasksControllers.isNotEmpty) const SizedBox(height: 4.0),
        ReorderableListView(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          onReorder: onReorder,
          proxyDecorator:
              (Widget child, int index, Animation<double> animation) {
                return Material(
                  elevation: 5,
                  color: AppColors.darkBackgroundColor,
                  surfaceTintColor: AppColors.darkBackgroundColor,
                  shadowColor: Colors.black,
                  child: ScaleTransition(
                    scale: animation.drive(
                      Tween(
                        begin: 1.0,
                        end: 1.05,
                      ).chain(CurveTween(curve: Curves.easeInOut)),
                    ),
                    child: child,
                  ),
                );
              },
          children: [
            for (int i = 0; i < subtasksKeys.length; i++)
              TaskSubtaskTextField(
                key: ValueKey(subtasksKeys[i]),
                color: color,
                controller: subtasksControllers[subtasksKeys[i]]!,
                subtaskIndex: i,
                keyboardFocusNode:
                    subtasksListenersFocusNodes[subtasksKeys[i]]!,
                textFocusNode: subtasksTextFocusNodes[subtasksKeys[i]]!,
                onKeyPressed: (keyEv) => onKeyPressed(subtasksKeys[i], keyEv),
              ),
          ],
        ),

        // ADD SUBTASK AND STAR
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(
              width: 40.0,
              height: 40.0,
              child: IconButton(
                onPressed: onAddSubtaskPressed,
                icon: Icon(
                  Icons.add_rounded,
                  color: AppColors.primaryLightTextColor,
                  size: 24.0,
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.all(0.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(
                      AppStyle.roundedCorners,
                    ),
                  ),
                  overlayColor: AppColors.primaryLightTextColor,
                ),
              ),
            ),
            SizedBox(
              width: 40.0,
              height: 40.0,
              child: IconButton(
                onPressed: onStarredPressed,
                icon: Icon(
                  isStarred ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: isStarred ? color : AppColors.primaryLightTextColor,
                  size: 24.0,
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.all(0.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(
                      AppStyle.roundedCorners,
                    ),
                  ),
                  overlayColor: AppColors.primaryLightTextColor,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
