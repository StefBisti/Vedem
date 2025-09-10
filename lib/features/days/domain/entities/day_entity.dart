import 'package:equatable/equatable.dart';

class DayEntity extends Equatable {
  final String dayId;
  final bool hearted;
  final int diamondsGain;
  final int diamondsProfit;

  const DayEntity({
    required this.dayId,
    this.hearted = false,
    this.diamondsGain = 0,
    this.diamondsProfit = 0,
  });

  DayEntity copyWith({
    String? dayId,
    bool? hearted,
    int? diamondsGain,
    int? diamondsProfit,
  }) {
    return DayEntity(
      dayId: dayId ?? this.dayId,
      hearted: hearted ?? this.hearted,
      diamondsGain: diamondsGain ?? this.diamondsGain,
      diamondsProfit: diamondsProfit ?? this.diamondsProfit,
    );
  }

  @override
  List<Object?> get props => [dayId, hearted, diamondsGain, diamondsProfit];
}
