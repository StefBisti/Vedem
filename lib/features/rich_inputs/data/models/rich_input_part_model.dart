import 'package:equatable/equatable.dart';
import 'package:vedem/features/rich_inputs/domain/entities/rich_input_part_entity.dart';
import '../../domain/entities/rich_input_type.dart';

class RichInputPartModel extends Equatable {
  final RichInputType type;
  final String content;
  final double padding;

  const RichInputPartModel({
    required this.type,
    required this.content,
    required this.padding,
  });

  RichInputPartEntity toEntity() =>
      RichInputPartEntity(type: type, content: content, padding: padding);

  factory RichInputPartModel.fromEntity(RichInputPartEntity e) =>
      RichInputPartModel(type: e.type, content: e.content, padding: e.padding);

  @override
  List<Object?> get props => [type, content, padding];
}
