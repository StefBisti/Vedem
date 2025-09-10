import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:vedem/core/error/error_messages.dart';
import 'package:vedem/core/error/exceptions.dart';
import 'package:vedem/features/days/data/datasources/days_data_source.dart';
import 'package:vedem/features/days/data/models/day_model.dart';

class DaysLocalDataSource implements DaysDataSource {
  final Box<DayModel> box;

  const DaysLocalDataSource({required this.box});

  @override
  Future<List<DayModel>> readDaysForMonth(String monthId) async {
    try {
      final List<DayModel> days = box.keys
          .where((k) => k.toString().startsWith(monthId))
          .map((k) => box.get(k)!)
          .toList();
      return days;
    } catch (e) {
      debugPrint(e.toString());
      throw LocalHiveException(message: loadHighlightsError);
    }
  }

  @override
  Future<void> writeDayData(String dayId, DayModel day) async {
    try {
      box.put(dayId, day);
    } catch (e) {
      debugPrint(e.toString());
      throw LocalHiveException(message: loadHighlightsError);
    }
  }
}
