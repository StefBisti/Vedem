import 'dart:async';
import 'dart:math';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vedem/core/error/error_messages.dart';
import 'package:vedem/features/rich_inputs/domain/entities/rich_input_entity.dart';
import 'package:vedem/features/rich_inputs/domain/entities/rich_input_part_entity.dart';
import 'package:vedem/features/rich_inputs/domain/entities/rich_input_type.dart';
import 'package:vedem/features/rich_inputs/domain/usecases/load_rich_input_use_case.dart';
import 'package:vedem/features/rich_inputs/domain/usecases/save_rich_input_use_case.dart';

part 'rich_inputs_state.dart';

class RichInputsCubit extends Cubit<RichInputsState> {
  final LoadRichInputUseCase loadRichInputUseCase;
  final SaveRichInputUseCase saveRichInputUseCase;

  RichInputsCubit({
    required this.loadRichInputUseCase,
    required this.saveRichInputUseCase,
  }) : super(const RichInputsState());

  Future<void> loadRichInput(String key) async {
    if (state.isLoading) {
      emit(state.copyWith(error: noOperationWhileIsLoadingError));
      return;
    }
    emit(state.copyWith(isLoading: true, error: null));
    final res = await loadRichInputUseCase.call(
      LoadRichInputUseCaseParams(key: key),
    );
    res.fold(
      (failure) =>
          emit(state.copyWith(isLoading: false, error: failure.message)),
      (richInput) => emit(
        RichInputsState(
          richInput: richInput..initializePartsIds(),
          isLoading: false,
          error: null,
        ),
      ),
    );
  }

  Future<void> saveRichInput(String key, RichInputEntity richInput) async {
    if (state.isLoading) {
      emit(state.copyWith(error: noOperationWhileIsLoadingError));
      return;
    }
    emit(state.copyWith(isLoading: true, error: null));
    final res = await saveRichInputUseCase.call(
      SaveRichInputUseCaseParams(key: key, newRichInput: richInput),
    );
    res.fold(
      (failure) =>
          emit(state.copyWith(isLoading: false, error: failure.message)),
      (unit) => emit(state.copyWith(isLoading: false, error: null)),
    );
  }

  // Rich Input Logic

  final double _paddingIncrement = 30, _maxPadding = 90;
  Timer? _debounce;

  @override
  Future<void> close() {
    if (_debounce != null) {
      _debounce!.cancel();
    }
    return super.close();
  }

  int _genId() => DateTime.now().microsecondsSinceEpoch;

  void onTextChanged(
    int index,
    String text,
    String richInputKey,
    Function(int) onDecorationAddedToId,
    Function(int) onSplit,
  ) {
    RichInputEntity newRichInput = state.richInput.copyWith();
    newRichInput.parts[index] = newRichInput.parts[index].copyWith(
      content: text,
    );
    int currentId = newRichInput.parts[index].id!;

    if (text.contains('\n')) {
      final int newLineIndex = text.indexOf('\n');
      final String otherText = text.substring(0, newLineIndex);
      final String thisText = text.substring(newLineIndex + 1, text.length);
      final RichInputType thisType = newRichInput.parts[index].type;
      newRichInput.parts[index] = newRichInput.parts[index].copyWith(
        content: thisText,
        type: thisType == RichInputType.title
            ? RichInputType.plain
            : thisType == RichInputType.checkboxChecked
            ? RichInputType.checkboxUnchecked
            : thisType,
      );
      onSplit(newRichInput.parts[index].id!);
      newRichInput.parts.insert(
        index,
        newRichInput.parts[index].copyWith(
          id: _genId(),
          content: otherText,
          type: thisType,
        ),
      );
      emit(state.copyWith(richInput: newRichInput));
      _debounce?.cancel();
      saveRichInput(richInputKey, newRichInput);
    } else if (index + 1 == newRichInput.parts.length) {
      newRichInput.parts.add(
        RichInputPartEntity(
          id: _genId(),
          type: RichInputType.plain,
          content: '',
          padding: 0.0,
        ),
      );
      emit(state.copyWith(richInput: newRichInput));
      _debounce?.cancel();
      saveRichInput(richInputKey, newRichInput);
    } else if (text.startsWith('-') &&
        newRichInput.parts[index].type == RichInputType.plain) {
      text = text.substring(1);
      newRichInput.parts[index] = newRichInput.parts[index].copyWith(
        content: text,
        type: RichInputType.bullet,
      );
      onDecorationAddedToId(currentId);
      emit(state.copyWith(richInput: newRichInput));
      _debounce?.cancel();
      saveRichInput(richInputKey, newRichInput);
    } else if (text.startsWith('[]') &&
        newRichInput.parts[index].type == RichInputType.plain) {
      text = text.substring(2);
      newRichInput.parts[index] = newRichInput.parts[index].copyWith(
        content: text,
        type: RichInputType.checkboxUnchecked,
      );
      onDecorationAddedToId(currentId);
      emit(state.copyWith(richInput: newRichInput));
      _debounce?.cancel();
      saveRichInput(richInputKey, newRichInput);
    } else if (text.startsWith('##') &&
        newRichInput.parts[index].type == RichInputType.plain) {
      text = text.substring(2);
      newRichInput.parts[index] = newRichInput.parts[index].copyWith(
        content: text,
        type: RichInputType.title,
      );
      onDecorationAddedToId(currentId);
      emit(state.copyWith(richInput: newRichInput));
      _debounce?.cancel();
      saveRichInput(richInputKey, newRichInput);
    } else if (text.startsWith('>>')) {
      text = text.substring(2);
      newRichInput.parts[index] = newRichInput.parts[index].copyWith(
        content: text,
        padding: min(
          newRichInput.parts[index].padding + _paddingIncrement,
          _maxPadding,
        ),
      );
      onDecorationAddedToId(currentId);
      emit(state.copyWith(richInput: newRichInput));
      _debounce?.cancel();
      saveRichInput(richInputKey, newRichInput);
    } else if (text.startsWith('<<')) {
      text = text.substring(2);
      newRichInput.parts[index] = newRichInput.parts[index].copyWith(
        content: text,
        padding: max(
          newRichInput.parts[index].padding - _paddingIncrement,
          0.0,
        ),
      );
      onDecorationAddedToId(currentId);
      emit(state.copyWith(richInput: newRichInput));
      _debounce?.cancel();
      saveRichInput(richInputKey, newRichInput);
    } else {
      emit(state.copyWith(richInput: newRichInput));
      _debounce?.cancel();
      _debounce = Timer(Duration(milliseconds: 1000), () {
        saveRichInput(richInputKey, state.richInput);
      });
    }
  }

  void onDeleteBeginning(
    int index,
    String richInputKey,
    Function(int, int) onRemoveId,
  ) {
    RichInputEntity newRichInput = state.richInput.copyWith();

    if (newRichInput.parts[index].type != RichInputType.plain) {
      newRichInput.parts[index] = newRichInput.parts[index].copyWith(
        type: RichInputType.plain,
      );
      emit(state.copyWith(richInput: newRichInput));
      _debounce?.cancel();
      saveRichInput(richInputKey, newRichInput);
    } else if (state.richInput.parts[index].padding > 0.0) {
      newRichInput.parts[index] = newRichInput.parts[index].copyWith(
        padding: max(
          state.richInput.parts[index].padding - _paddingIncrement,
          0.0,
        ),
      );
      emit(state.copyWith(richInput: newRichInput));
      _debounce?.cancel();
      saveRichInput(richInputKey, newRichInput);
    } else if (state.richInput.parts[index].content.isEmpty) {
      if (index != 0) {
        onRemoveId(
          newRichInput.parts[index].id!,
          newRichInput.parts[index - 1].id!,
        );
        newRichInput.parts.removeAt(index);

        emit(state.copyWith(richInput: newRichInput));
        _debounce?.cancel();
        saveRichInput(richInputKey, newRichInput);
      }
    } else if (index > 0) {
      newRichInput.parts[index - 1] = newRichInput.parts[index - 1].copyWith(
        content:
            newRichInput.parts[index - 1].content +
            newRichInput.parts[index].content,
      );
      onRemoveId(
        newRichInput.parts[index].id!,
        newRichInput.parts[index - 1].id!,
      );
      newRichInput.parts.removeAt(index);
      emit(state.copyWith(richInput: newRichInput));
      _debounce?.cancel();
      saveRichInput(richInputKey, newRichInput);
    }
  }

  void onCheckChanged(int index, bool v, String richInputKey) {
    RichInputEntity newRichInput = state.richInput.copyWith();
    newRichInput.parts[index] = newRichInput.parts[index].copyWith(
      type: v == true
          ? RichInputType.checkboxChecked
          : RichInputType.checkboxUnchecked,
    );
    emit(state.copyWith(richInput: newRichInput));
    _debounce?.cancel();
    saveRichInput(richInputKey, newRichInput);
  }

  void changeItemIndex(int oldIndex, int newIndex, String richInputKey) {
    if (newIndex > oldIndex) newIndex -= 1;

    RichInputEntity newRichInput = state.richInput.copyWith();
    final richInput = newRichInput.parts.removeAt(oldIndex);
    newRichInput.parts.insert(newIndex, richInput);

    emit(state.copyWith(richInput: newRichInput));
    _debounce?.cancel();
    saveRichInput(richInputKey, newRichInput);
  }
}
