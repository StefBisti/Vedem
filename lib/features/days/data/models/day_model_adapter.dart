import 'package:hive/hive.dart';
import 'package:vedem/core/hive/hive_constants.dart';
import 'package:vedem/features/days/data/models/day_model.dart';

class DayModelAdapter extends TypeAdapter<DayModel> {
  @override
  final int typeId = dayModelId;

  @override
  DayModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DayModel(
      dayId: (fields[0] as String),
      hearted: (fields[1] as bool),
      diamonds: (fields[2] as int),
    );
  }

  @override
  void write(BinaryWriter writer, DayModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.dayId)
      ..writeByte(1)
      ..write(obj.hearted)
      ..writeByte(2)
      ..write(obj.diamonds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DayModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
