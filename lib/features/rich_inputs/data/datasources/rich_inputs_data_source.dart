import 'package:vedem/features/rich_inputs/data/models/rich_input_model.dart';

abstract interface class RichInputsDataSource {
  Future<RichInputModel> readRichInput(String dayId);
  Future<void> writeRichInput(String dayId, RichInputModel richInput);
}
