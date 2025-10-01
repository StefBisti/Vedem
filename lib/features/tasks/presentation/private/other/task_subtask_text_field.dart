import 'package:flutter/material.dart';
import 'package:vedem/core/style/app_colors.dart';
import 'package:vedem/core/style/app_text_styles.dart';

class TaskSubtaskTextField extends StatelessWidget {
  const TaskSubtaskTextField({
    super.key,
    required this.color,
    required this.controller,
    required this.keyboardFocusNode,
    required this.textFocusNode,
    required this.subtaskIndex,
    required this.onKeyPressed,
  });

  final Color color;
  final TextEditingController controller;
  final FocusNode keyboardFocusNode;
  final FocusNode textFocusNode;
  final int subtaskIndex;
  final Function(KeyEvent) onKeyPressed;

  @override
  Widget build(BuildContext context) {
    return TextSelectionTheme(
      data: TextSelectionThemeData(
        cursorColor: AppColors.primaryLightTextColor,
        selectionHandleColor: AppColors.primaryLightTextColor,
        selectionColor: color.withAlpha(64),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0.0,
            top: 2.0,
            bottom: 0.0,
            width: 24.0,
            child: Listener(
              onPointerDown: (_) => FocusScope.of(context).unfocus(),
              child: ReorderableDragStartListener(
                index: subtaskIndex,
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
          Positioned(
            left: 4.0,
            top: 5.0,
            child: IgnorePointer(
              child: Container(
                width: 16.0,
                height: 16.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.0),
                  border: BoxBorder.all(color: color, width: 1.5),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsetsGeometry.only(left: 24.0, top: 2.0),
            child: KeyboardListener(
              focusNode: keyboardFocusNode,
              onKeyEvent: onKeyPressed,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: 16.0),
                child: TextField(
                  controller: controller,
                  focusNode: textFocusNode,
                  maxLines: null,
                  minLines: 1,
                  keyboardType: TextInputType.multiline,
                  textCapitalization: TextCapitalization.sentences,
                  textAlignVertical: TextAlignVertical.top,
                  style: AppTextStyles.content.copyWith(color: color),
                  cursorRadius: Radius.circular(4.0),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 4.0),
                    border: InputBorder.none,
                    hintText: 'Subtask',
                    hintStyle: AppTextStyles.content.copyWith(
                      color: AppColors.secondaryLightTextColor,
                    ),
                    isCollapsed: true,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
