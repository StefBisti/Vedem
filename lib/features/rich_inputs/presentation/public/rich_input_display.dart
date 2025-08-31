import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vedem/core/style/app_colors.dart';
import 'package:vedem/core/utils/misc_utils.dart';
import 'package:vedem/features/rich_inputs/domain/entities/rich_input_part_entity.dart';
import 'package:vedem/features/rich_inputs/presentation/cubit/rich_inputs_cubit.dart';
import 'package:vedem/features/rich_inputs/presentation/private/rich_input_part_view.dart';

class RichInputDisplay extends StatefulWidget {
  final String richInputKey;

  const RichInputDisplay({super.key, required this.richInputKey});

  @override
  State<RichInputDisplay> createState() => _RichInputDisplayState();
}

class _RichInputDisplayState extends State<RichInputDisplay> {
  final Map<int, TextEditingController> _controllers = {};
  final Map<int, FocusNode> _textFieldFocusNodes = {};
  final Map<int, FocusNode> _listenerFocusNodes = {};
  final Map<int, FocusNode> _dummyFocusNodes = {};

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    for (final f in _textFieldFocusNodes.values) {
      f.dispose();
    }
    for (final f in _dummyFocusNodes.values) {
      f.dispose();
    }
    for (final f in _listenerFocusNodes.values) {
      f.dispose();
    }
    super.dispose();
  }

  TextEditingController _getControllerFor(RichInputPartEntity part) {
    if (part.id == null) {
      debugPrint('Error');
      return TextEditingController();
    }
    if (_controllers.containsKey(part.id!)) {
      TextEditingController c = _controllers[part.id!]!;
      int selectionIndex = c.selection.baseOffset;
      if (selectionIndex > part.content.length) {
        selectionIndex = 0;
      }
      c.value = TextEditingValue(
        text: part.content,
        selection: TextSelection.collapsed(offset: selectionIndex),
      );
      return c;
    }
    final newController = TextEditingController(text: part.content);
    _controllers[part.id!] = newController;
    // instead of add listener, i use onChanged in partView for easy controller changes
    return newController;
  }

  FocusNode _getTextFieldFocusFor(
    RichInputPartEntity part, {
    bool alsoRequestFocus = false,
  }) {
    if (part.id == null) {
      debugPrint('Error');
      return FocusNode();
    }
    if (_textFieldFocusNodes.containsKey(part.id!)) {
      return _textFieldFocusNodes[part.id!]!;
    }
    final newFocus = FocusNode();
    _textFieldFocusNodes[part.id!] = newFocus;

    if (alsoRequestFocus) {
      newFocus.requestFocus();
    }

    return newFocus;
  }

  FocusNode _getListenerFocusFor(RichInputPartEntity part) {
    if (part.id == null) {
      debugPrint('Error');
      return FocusNode();
    }
    if (_listenerFocusNodes.containsKey(part.id!)) {
      return _listenerFocusNodes[part.id!]!;
    }
    final newFocus = FocusNode();
    _listenerFocusNodes[part.id!] = newFocus;
    return newFocus;
  }

  FocusNode _getDummyFocusFor(RichInputPartEntity part) {
    if (part.id == null) {
      debugPrint('Error');
      return FocusNode();
    }
    if (_dummyFocusNodes.containsKey(part.id!)) {
      return _dummyFocusNodes[part.id!]!;
    }
    final newFocus = FocusNode();
    _dummyFocusNodes[part.id!] = newFocus;
    return newFocus;
  }

  void _handleDecorationAddedToId(int partId) {
    _controllers[partId]!.selection = TextSelection.collapsed(offset: 0);

    _dummyFocusNodes[partId]!.requestFocus();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _textFieldFocusNodes[partId]!.requestFocus();
    });
  }

  void _handleOnRemoveId(int partId, int requestFocusForPartId) {
    _textFieldFocusNodes.remove(partId);
    _dummyFocusNodes.remove(partId);
    _listenerFocusNodes.remove(partId);
    _controllers.remove(partId);

    _textFieldFocusNodes[requestFocusForPartId]!.requestFocus();
    _controllers[requestFocusForPartId]!.selection = TextSelection.collapsed(
      offset: _controllers[requestFocusForPartId]!.text.length,
    );
  }

  void _handleOnSplit(int focusedPartId) {
    _controllers[focusedPartId]!.selection = TextSelection.collapsed(offset: 0);
  }

  void _onReorder(int oldIndex, int newIndex) {
    context.read<RichInputsCubit>().changeItemIndex(
      oldIndex,
      newIndex,
      widget.richInputKey,
    );
  }

  void _onTextChanged(int partIndex, String text) {
    context.read<RichInputsCubit>().onTextChanged(
      partIndex,
      text,
      widget.richInputKey,
      _handleDecorationAddedToId,
      _handleOnSplit,
    );
  }

  void _onKeyPress(int partIndex, int partId, KeyEvent key) {
    if (key is KeyDownEvent &&
        key.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[partId]!.selection.baseOffset == 0) {
      context.read<RichInputsCubit>().onDeleteBeginning(
        partIndex,
        widget.richInputKey,
        _handleOnRemoveId,
      );
    }
  }

  void _onCheckChanged(int partIndex, bool value) {
    context.read<RichInputsCubit>().onCheckChanged(
      partIndex,
      value,
      widget.richInputKey,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RichInputsCubit, RichInputsState>(
      listener: (context, state) {
        if (state.error != null) {
          MiscUtils.showSnackBar(context, state.error!);
        }
      },
      builder: (context, state) {
        return ReorderableListView(
          onReorder: _onReorder,
          buildDefaultDragHandles: false,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          proxyDecorator:
              (Widget child, int index, Animation<double> animation) {
                return Material(
                  elevation: 5,
                  color: AppColors.lightBackgroundColor,
                  surfaceTintColor: AppColors.lightBackgroundColor,
                  shadowColor: Colors.black54,
                  child: ScaleTransition(
                    scale: animation.drive(
                      Tween(
                        begin: 1.0,
                        end: 1.1,
                      ).chain(CurveTween(curve: Curves.easeInOut)),
                    ),
                    child: child,
                  ),
                );
              },
          children: [
            for (int i = 0; i < state.richInput.parts.length; i++)
              RichInputPartView(
                key: ValueKey(state.richInput.parts[i].id!),
                data: state.richInput.parts[i],
                controller: _getControllerFor(state.richInput.parts[i]),
                textFieldFocusNode: _getTextFieldFocusFor(
                  state.richInput.parts[i],
                ),
                listenerFocusNode: _getListenerFocusFor(
                  state.richInput.parts[i],
                ),
                dummyFocusNode: _getDummyFocusFor(state.richInput.parts[i]),
                showHint: state.richInput.parts.length == 1,
                index: i,
                globalHorizontalPadding: 16.0,
                onTextChanged: (s) => _onTextChanged(i, s),
                onKeyPress: (key) =>
                    _onKeyPress(i, state.richInput.parts[i].id!, key),
                onCheckedChanged: (v) => _onCheckChanged(i, v!),
              ),
          ],
        );
      },
    );
  }
}
