import 'package:equatable/equatable.dart';
import 'package:vedem/features/days/domain/entities/day_entity.dart';

class DayModel extends Equatable {
  final String dayId;
  final bool hearted;
  final int diamondsGain;
  final int diamondsProfit;

  const DayModel({
    required this.dayId,
    required this.hearted,
    required this.diamondsGain,
    required this.diamondsProfit,
  });

  DayModel copyWith({
    String? dayId,
    bool? hearted,
    int? diamondsGain,
    int? diamondsProfit,
  }) {
    return DayModel(
      dayId: dayId ?? this.dayId,
      hearted: hearted ?? this.hearted,
      diamondsGain: diamondsGain ?? this.diamondsGain,
      diamondsProfit: diamondsProfit ?? this.diamondsProfit,
    );
  }

  DayEntity toEntity() => DayEntity(
    dayId: dayId,
    hearted: hearted,
    diamondsGain: diamondsGain,
    diamondsProfit: diamondsProfit,
  );

  factory DayModel.fromEntity(DayEntity e) => DayModel(
    dayId: e.dayId,
    hearted: e.hearted,
    diamondsGain: e.diamondsGain,
    diamondsProfit: e.diamondsProfit,
  );

  @override
  List<Object?> get props => [dayId, hearted, diamondsGain, diamondsProfit];
}
