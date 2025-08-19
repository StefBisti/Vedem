import 'package:equatable/equatable.dart';

class TaskEntity extends Equatable {
  final int taskId;
  final int categoryId;
  final String content;
  final bool isRecurring;
  final int diamonds;
  final bool isDone;

  const TaskEntity({
    required this.taskId,
    required this.categoryId,
    required this.content,
    required this.isRecurring,
    required this.diamonds,
    required this.isDone,
  });

  @override
  List<Object?> get props => [taskId, categoryId, content, diamonds, isRecurring, isDone];
}
