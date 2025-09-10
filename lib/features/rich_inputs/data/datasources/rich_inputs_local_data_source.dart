import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';
import 'package:vedem/core/error/error_messages.dart';
import 'package:vedem/core/error/exceptions.dart';
import 'package:vedem/features/rich_inputs/data/datasources/rich_inputs_data_source.dart';
import 'package:vedem/features/rich_inputs/data/models/rich_input_model.dart';

class RichInputsLocalDataSource implements RichInputsDataSource {
  final Box<RichInputModel> box;

  RichInputsLocalDataSource({required this.box});

  @override
  Future<RichInputModel> readRichInput(String key) {
    try {
      final RichInputModel? richInput = box.get(
        key,
        defaultValue: RichInputModel.empty(),
      );
      return Future.value(richInput);
    } catch (e) {
      debugPrint(e.toString());
      throw LocalHiveException(message: loadRichInputError);
    }
  }

  @override
  Future<void> writeRichInput(String dayId, RichInputModel richInput) {
    try {
      box.put(dayId, richInput);
      return Future.value();
    } catch (e) {
      debugPrint(e.toString());
      throw LocalHiveException(message: saveRichInputError);
    }
  }
}
