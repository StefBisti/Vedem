import 'package:vedem/features/days/data/models/day_model.dart';

abstract interface class DaysDataSource {
  Future<List<DayModel>> readDaysForMonth(String monthId);
  Future<void> writeDayData(String dayId, DayModel day);
}
