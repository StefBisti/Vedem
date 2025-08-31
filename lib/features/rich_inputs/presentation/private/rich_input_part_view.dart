import 'package:flutter/material.dart';
import 'package:vedem/core/style/app_colors.dart';
import 'package:vedem/core/style/app_text_styles.dart';
import 'package:vedem/features/rich_inputs/domain/entities/rich_input_part_entity.dart';
import 'package:vedem/features/rich_inputs/domain/entities/rich_input_type.dart';

class RichInputPartView extends StatelessWidget {
  final RichInputPartEntity data;
  final Function(bool? v) onCheckedChanged;
  final Function(KeyEvent) onKeyPress;
  final Function(String) onTextChanged;
  final FocusNode textFieldFocusNode, listenerFocusNode, dummyFocusNode;
  final TextEditingController controller;
  final bool showHint;
  final int index;
  final double globalHorizontalPadding;
  final double textVerticalPadding = 4.0;
  final double titleVerticalPadding = 4.0;
  final double textHorizontalPadding = 8.0;

  const RichInputPartView({
    super.key,
    required this.data,
    required this.textFieldFocusNode,
    required this.listenerFocusNode,
    required this.dummyFocusNode,
    required this.controller,
    required this.showHint,
    required this.index,
    required this.globalHorizontalPadding,
    required this.onCheckedChanged,
    required this.onKeyPress,
    required this.onTextChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: 0.0,
          top: 0.0,
          bottom: 0.0,
          width: globalHorizontalPadding + data.padding - textHorizontalPadding,
          child: Listener(
            onPointerDown: (_) => FocusScope.of(context).unfocus(),
            child: ReorderableDragStartListener(
              index: index,
              child: Container(color: Colors.transparent),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            left:
                globalHorizontalPadding + data.padding - textHorizontalPadding,
            right: globalHorizontalPadding,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Visibility(
                visible:
                    data.type == RichInputType.checkboxChecked ||
                    data.type == RichInputType.checkboxUnchecked,
                child: Padding(
                  padding: EdgeInsets.only(
                    left: textHorizontalPadding,
                    top: textVerticalPadding + 2.0,
                  ),
                  child: SizedBox(
                    width: 20.0,
                    height: 20.0,
                    child: Checkbox(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.circular(4.0),
                      ),
                      side: BorderSide(
                        color: AppColors.primaryDarkTextColor,
                        width: 1.0,
                      ),
                      activeColor: AppColors.primaryDarkTextColor,
                      checkColor: AppColors.lightBackgroundColor,
                      value: data.type == RichInputType.checkboxChecked,
                      onChanged: onCheckedChanged,
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: data.type == RichInputType.bullet,
                child: Padding(
                  padding: EdgeInsets.only(
                    left: textHorizontalPadding,
                    top: textVerticalPadding,
                  ),
                  child: SizedBox(
                    width: 20.0,
                    height: 20.0,
                    child: Icon(
                      Icons.circle,
                      color: AppColors.primaryDarkTextColor,
                      size: 8.0,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: KeyboardListener(
                  focusNode: listenerFocusNode,
                  onKeyEvent: onKeyPress,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: 16.0),
                    child: TextField(
                      controller: controller,
                      focusNode: textFieldFocusNode,
                      onChanged: onTextChanged,
                      maxLines: null,
                      minLines: 1,
                      keyboardType: TextInputType.multiline,
                      textCapitalization: TextCapitalization.sentences,
                      textAlignVertical: TextAlignVertical.top,
                      style: data.type == RichInputType.title
                          ? AppTextStyles.heading
                          : AppTextStyles.content.copyWith(
                              decoration:
                                  (data.type == RichInputType.checkboxChecked)
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                      cursorColor: AppColors.primaryDarkTextColor,
                      cursorWidth: 2,
                      decoration: InputDecoration(
                        isCollapsed: true,
                        contentPadding: data.type == RichInputType.title
                            ? EdgeInsets.only(
                                top: titleVerticalPadding,
                                bottom: titleVerticalPadding,
                                left: textHorizontalPadding,
                              )
                            : EdgeInsets.only(
                                top: textVerticalPadding,
                                bottom: textVerticalPadding,
                                left: textHorizontalPadding,
                              ),
                        border: InputBorder.none,
                        hintText: !showHint
                            ? ""
                            : (data.type == RichInputType.checkboxChecked ||
                                  data.type == RichInputType.checkboxUnchecked)
                            ? "Write something to do"
                            : data.type == RichInputType.bullet
                            ? "Write a bullet item"
                            : "What's on your mind?",
                        hintStyle: AppTextStyles.content.copyWith(
                          color: AppColors.primaryDarkTextColor.withAlpha(100),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 0.0,
                width: 0.0,
                child: TextField(focusNode: dummyFocusNode),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
