import 'package:equatable/equatable.dart';

class TaskEntity extends Equatable {
  final int id;
  final int categoryId;
  final String content;
  final bool isRecurring;
  final int diamonds;
  final bool isCompleted;

  const TaskEntity({
    required this.id,
    required this.categoryId,
    required this.content,
    required this.isRecurring,
    required this.diamonds,
    required this.isCompleted,
  });

  @override
  List<Object?> get props => [id, categoryId, content, diamonds, isRecurring, isCompleted];
}
