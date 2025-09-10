import 'package:hive/hive.dart';
import 'package:vedem/core/hive/hive_constants.dart';
import 'package:vedem/features/highlights/data/models/highlight_model.dart';

class HighlightModelAdapter extends TypeAdapter<HighlightModel> {
  @override
  final int typeId = highlightModelId;

  @override
  HighlightModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HighlightModel(
      dayId: (fields[0] as String),
      headerImagePath: (fields[1] as String),
      carouselImagePath: (fields[2] as String),
      galleryImagePath: (fields[3] as String),
    );
  }

  @override
  void write(BinaryWriter writer, HighlightModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.dayId)
      ..writeByte(1)
      ..write(obj.headerImagePath)
      ..writeByte(2)
      ..write(obj.carouselImagePath)
      ..writeByte(3)
      ..write(obj.galleryImagePath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HighlightModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
