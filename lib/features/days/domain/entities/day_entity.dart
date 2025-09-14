import 'package:equatable/equatable.dart';

class DayEntity extends Equatable {
  final String dayId;
  final bool hearted;
  final int diamonds;
  final bool isInitialized;

  const DayEntity({
    required this.dayId,
    this.hearted = false,
    this.diamonds = 0,
    this.isInitialized = false,
  });

  DayEntity copyWith({
    String? dayId,
    bool? hearted,
    int? diamonds,
    bool? isInitialized,
  }) {
    return DayEntity(
      dayId: dayId ?? this.dayId,
      hearted: hearted ?? this.hearted,
      diamonds: diamonds ?? this.diamonds,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }

  @override
  List<Object?> get props => [dayId, hearted, diamonds, isInitialized];
}
