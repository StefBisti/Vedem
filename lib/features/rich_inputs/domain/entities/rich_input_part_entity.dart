import 'package:equatable/equatable.dart';
import 'package:vedem/features/rich_inputs/domain/entities/rich_input_type.dart';

class RichInputPartEntity extends Equatable {
  final int? id;
  final RichInputType type;
  final String content;
  final double padding;

  const RichInputPartEntity({
    this.id,
    required this.type,
    required this.content,
    required this.padding,
  });

  RichInputPartEntity copyWith({
    int? id,
    RichInputType? type,
    String? content,
    double? padding,
  }) {
    return RichInputPartEntity(
      id: id ?? this.id,
      type: type ?? this.type,
      content: content ?? this.content,
      padding: padding ?? this.padding,
    );
  }

  @override
  List<Object?> get props => [id, type, content, padding];
}
