import 'package:hive/hive.dart';
import 'package:vedem/core/hive/hive_constants.dart';
import 'package:vedem/features/rich_inputs/data/models/rich_input_model.dart';
import 'package:vedem/features/rich_inputs/data/models/rich_input_part_model.dart';

class RichInputModelAdapter extends TypeAdapter<RichInputModel> {
  @override
  final int typeId = richInputModelId;

  @override
  RichInputModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RichInputModel(
      parts: (fields[0] as List).cast<RichInputPartModel>(),
    );
  }

  @override
  void write(BinaryWriter writer, RichInputModel obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.parts);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RichInputModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
