import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vedem/core/error/error_messages.dart';
import 'package:vedem/features/rich_inputs/domain/entities/rich_input_entity.dart';
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
    // change to key
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
        RichInputsState(richInput: richInput, isLoading: false, error: null),
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
}
