import 'package:hive_flutter/hive_flutter.dart';
import 'package:vedem/core/hive/hive_constants.dart';
import 'package:vedem/features/rich_inputs/data/models/rich_input_model.dart';
import 'package:vedem/features/rich_inputs/data/models/rich_input_model_adapter.dart';
import 'package:vedem/features/rich_inputs/data/models/rich_input_part_model_adapter.dart';
import 'package:vedem/features/rich_inputs/data/models/rich_input_type_adapter.dart';

class AppHive {
  static Future<Box> initRichInputs() async {
    await Hive.initFlutter();
    Hive.registerAdapter(RichInputTypeAdapter());
    Hive.registerAdapter(RichInputPartModelAdapter());
    Hive.registerAdapter(RichInputModelAdapter());
    return await Hive.openBox<RichInputModel>(richInputId);
  }
}
