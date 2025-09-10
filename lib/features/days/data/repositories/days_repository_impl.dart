import 'package:fpdart/fpdart.dart';
import 'package:vedem/core/error/exceptions.dart';
import 'package:vedem/core/error/failures.dart';
import 'package:vedem/core/utils/time_utils.dart';
import 'package:vedem/features/days/data/datasources/days_data_source.dart';
import 'package:vedem/features/days/data/models/day_model.dart';
import 'package:vedem/features/days/domain/entities/day_entity.dart';
import 'package:vedem/features/days/domain/repositories/days_repository.dart';

class DaysRepositoryImpl implements DaysRepository {
  final DaysDataSource dataSource;

  const DaysRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, List<DayEntity>>> loadDaysForMonth(
    String monthId,
  ) async {
    try {
      List<DayModel> days = await dataSource.readDaysForMonth(monthId);
      List<DayEntity> daysEntities = days.map((m) => m.toEntity()).toList();

      if (monthId == TimeUtils.thisMonthId &&
          days.all((m) => m.dayId != TimeUtils.thisDayId)) {
        DayEntity newEntity = DayEntity(dayId: TimeUtils.thisDayId);
        daysEntities.add(newEntity);
        dataSource.writeDayData(
          TimeUtils.thisDayId,
          DayModel.fromEntity(newEntity),
        );
      }
      return right(daysEntities);
    } on LocalHiveException catch (e) {
      return left(LocalHiveFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateDay(
    String dayId,
    DayEntity newDay,
  ) async {
    try {
      DayModel newDayModel = DayModel.fromEntity(newDay);
      await dataSource.writeDayData(dayId, newDayModel);
      return right(unit);
    } on LocalHiveException catch (e) {
      return left(LocalHiveFailure(e.message));
    }
  }
}
