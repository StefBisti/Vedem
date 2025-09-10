part of 'days_cubit.dart';

class DaysState extends Equatable {
  final List<DayEntity> days;
  final bool isLoading;
  final String? error;

  const DaysState({
    this.days = const [],
    this.isLoading = false,
    this.error,
  });

  DaysState copyWith({
    List<DayEntity>? days,
    bool? isLoading,
    String? error,
    int? stateVersion,
  }) {
    return DaysState(
      days: days ?? this.days,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List<Object> get props => [days, isLoading, error ?? ''];
}
