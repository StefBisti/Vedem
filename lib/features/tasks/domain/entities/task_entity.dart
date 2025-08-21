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

  TaskEntity copyWith({
    int? taskId,
    int? categoryId,
    String? content,
    bool? isRecurring,
    int? diamonds,
    bool? isDone,
  }) {
    return TaskEntity(
      taskId: taskId ?? this.taskId,
      categoryId: categoryId ?? this.categoryId,
      content: content ?? this.content,
      isRecurring: isRecurring ?? this.isRecurring,
      diamonds: diamonds ?? this.diamonds,
      isDone: isDone ?? this.isDone,
    );
  }

  @override
  List<Object?> get props => [
    taskId,
    categoryId,
    content,
    diamonds,
    isRecurring,
    isDone,
  ];
}
