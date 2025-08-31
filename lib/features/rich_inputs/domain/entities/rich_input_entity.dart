import 'package:equatable/equatable.dart';
import 'package:vedem/features/rich_inputs/domain/entities/rich_input_part_entity.dart';

class RichInputEntity extends Equatable {
  final List<RichInputPartEntity> parts;

  const RichInputEntity({required this.parts});

  RichInputEntity copyWith({List<RichInputPartEntity>? parts}) {
    return RichInputEntity(parts: parts ?? this.parts);
  }

  void initializePartsIds() {
    for (int i = 0; i < parts.length; i++) {
      parts[i] = parts[i].copyWith(id: i);
    }
  }

  @override
  List<Object?> get props => [parts];
}
