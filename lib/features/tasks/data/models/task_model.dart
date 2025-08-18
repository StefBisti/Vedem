import 'package:vedem/features/tasks/domain/entities/task_entity.dart';

class TaskModel extends TaskEntity {
  const TaskModel({
    required super.id,
    required super.categoryId,
    required super.content,
    required super.isRecurring,
    required super.diamonds,
    required super.isCompleted
  });

  TaskModel copyWith({
    int? id,
    int? categoryId,
    String? content,
    bool? isRecurring,
    int? diamonds,
    bool? isCompleted,
  }) {
    return TaskModel(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      content: content ?? this.content,
      isRecurring: isRecurring ?? this.isRecurring,
      diamonds: diamonds ?? this.diamonds,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] as int,
      categoryId: map['category_id'] as int,
      content: map['content'] as String,
      isRecurring: (map['is_recurring'] as int) == 1,
      diamonds: map['diamonds'] as int,
      isCompleted: (map['is_completed'] as int) == 1,
    );
  }
}
