import 'package:hive/hive.dart';
import 'package:vedem/core/hive/hive_constants.dart';
import '../../domain/entities/rich_input_type.dart';

class RichInputTypeAdapter extends TypeAdapter<RichInputType> {
  @override
  final int typeId = richInputTypelId;

  @override
  RichInputType read(BinaryReader reader) {
    final int index = reader.readByte();
    return RichInputType.values[index];
  }

  @override
  void write(BinaryWriter writer, RichInputType obj) {
    writer.writeByte(obj.index);
  }
}
