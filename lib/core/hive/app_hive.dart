import 'package:hive_flutter/hive_flutter.dart';
import 'package:vedem/core/hive/hive_constants.dart';
import 'package:vedem/features/days/data/models/day_model.dart';
import 'package:vedem/features/days/data/models/day_model_adapter.dart';
import 'package:vedem/features/highlights/data/models/highlight_model.dart';
import 'package:vedem/features/highlights/data/models/highlight_model_adapter.dart';
import 'package:vedem/features/rich_inputs/data/models/rich_input_model.dart';
import 'package:vedem/features/rich_inputs/data/models/rich_input_model_adapter.dart';
import 'package:vedem/features/rich_inputs/data/models/rich_input_part_model_adapter.dart';
import 'package:vedem/features/rich_inputs/data/models/rich_input_type_adapter.dart';

class AppHive {
  static Future initHive() async {
    await Hive.initFlutter();
  }

  static Future<Box<RichInputModel>> initRichInputs() async {
    Hive.registerAdapter(RichInputTypeAdapter());
    Hive.registerAdapter(RichInputPartModelAdapter());
    Hive.registerAdapter(RichInputModelAdapter());
    return await Hive.openBox<RichInputModel>(richInputId);
  }

  static Future<Box<HighlightModel>> initHighlights() async {
    Hive.registerAdapter(HighlightModelAdapter());
    final box = await Hive.openBox<HighlightModel>(highlightId);
    return box;
  }

  static Future<Box<DayModel>> initDays() async {
    Hive.registerAdapter(DayModelAdapter());
    final box = await Hive.openBox<DayModel>(daysId);
    return box;
  }
}
