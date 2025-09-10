import 'package:fpdart/fpdart.dart';
import 'package:vedem/core/error/failures.dart';
import 'package:vedem/features/days/domain/entities/day_entity.dart';

abstract interface class DaysRepository {
  Future<Either<Failure, List<DayEntity>>> loadDaysForMonth(String monthId);
  Future<Either<Failure, Unit>> updateDay(String dayId, DayEntity newDay);
}