import 'package:equatable/equatable.dart';

import 'rich_input_part_model.dart';
import '../../domain/entities/rich_input_entity.dart';

class RichInputModel extends Equatable {
  final List<RichInputPartModel> parts;

  const RichInputModel({required this.parts});

  RichInputEntity toEntity() => RichInputEntity(
    parts: parts.map((m) => m.toEntity()).toList(),
  );

  factory RichInputModel.fromEntity(RichInputEntity e) => RichInputModel(
    parts: e.parts.map((e) => RichInputPartModel.fromEntity(e)).toList(),
  );

  factory RichInputModel.empty() => RichInputModel(
    parts: [RichInputPartModel.empty()],
  );

  @override
  List<Object?> get props => [parts];
}
