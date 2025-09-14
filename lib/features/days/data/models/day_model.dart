import 'package:equatable/equatable.dart';
import 'package:vedem/features/days/domain/entities/day_entity.dart';

class DayModel extends Equatable {
  final String dayId;
  final bool hearted;
  final int diamonds;

  const DayModel({
    required this.dayId,
    required this.hearted,
    required this.diamonds,
  });

  DayModel copyWith({String? dayId, bool? hearted, int? diamonds}) {
    return DayModel(
      dayId: dayId ?? this.dayId,
      hearted: hearted ?? this.hearted,
      diamonds: diamonds ?? this.diamonds,
    );
  }

  DayEntity toEntity() => DayEntity(
    dayId: dayId,
    hearted: hearted,
    diamonds: diamonds,
    isInitialized: true,
  );

  factory DayModel.fromEntity(DayEntity e) =>
      DayModel(dayId: e.dayId, hearted: e.hearted, diamonds: e.diamonds);

  @override
  List<Object?> get props => [dayId, hearted, diamonds];
}
