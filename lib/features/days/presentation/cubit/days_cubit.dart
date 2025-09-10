import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vedem/core/error/error_messages.dart';
import 'package:vedem/features/days/domain/entities/day_entity.dart';
import 'package:vedem/features/days/domain/repositories/days_repository.dart';

part 'days_state.dart';

class DaysCubit extends Cubit<DaysState> {
  final DaysRepository _repository;

  DaysCubit(this._repository) : super(DaysState());

  Future<void> loadDaysForMonth(String monthId) async {
    if (isClosed) return;
    if (state.isLoading) {
      emit(state.copyWith(error: noOperationWhileIsLoadingError));
      return;
    }
    emit(state.copyWith(isLoading: true, error: null));

    final res = await _repository.loadDaysForMonth(monthId);
    res.fold(
      (failure) {
        if (!isClosed) {
          emit(state.copyWith(isLoading: false, error: failure.message));
        }
      },
      (days) {
        if (!isClosed) {
          emit(state.copyWith(days: days, isLoading: false));
        }
      },
    );
  }

  Future<void> toggleHeartForDay(int dayIndexInState) async {
    if (isClosed) return;
    if (state.isLoading) {
      emit(state.copyWith(error: noOperationWhileIsLoadingError));
      return;
    }

    List<DayEntity> optimisticDays = List.from(state.days);
    optimisticDays[dayIndexInState] = optimisticDays[dayIndexInState].copyWith(
      hearted: !optimisticDays[dayIndexInState].hearted,
    );
    emit(DaysState(days: optimisticDays, isLoading: true, error: null));

    final res = await _repository.updateDay(
      state.days[dayIndexInState].dayId,
      optimisticDays[dayIndexInState],
    );
    res.fold(
      (failure) {
        if (!isClosed) {
          List<DayEntity> reconcileDays = List.from(optimisticDays);
          reconcileDays[dayIndexInState].copyWith(
            hearted: !reconcileDays[dayIndexInState].hearted,
          );
          emit(
            DaysState(
              days: reconcileDays,
              isLoading: false,
              error: failure.message,
            ),
          );
        }
      },
      (unit) {
        if (!isClosed) {
          emit(state.copyWith(isLoading: false));
        }
      },
    );
  }

  Future<void> shareDay(int dayIndexInState) async {}
}
