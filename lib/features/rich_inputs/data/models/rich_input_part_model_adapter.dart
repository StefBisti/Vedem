import 'package:hive/hive.dart';
import 'package:vedem/core/hive/hive_constants.dart';
import 'package:vedem/features/rich_inputs/data/models/rich_input_part_model.dart';
import 'package:vedem/features/rich_inputs/domain/entities/rich_input_type.dart';

class RichInputPartModelAdapter extends TypeAdapter<RichInputPartModel> {
  @override
  final int typeId = richInputPartModelId;

  @override
  RichInputPartModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RichInputPartModel(
      type: fields[0] as RichInputType,
      content: fields[1] as String,
      padding: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, RichInputPartModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.type)
      ..writeByte(1)
      ..write(obj.content)
      ..writeByte(2)
      ..write(obj.padding);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RichInputPartModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
