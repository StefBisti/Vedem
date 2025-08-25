import 'package:vedem/core/database/database_keys.dart';
import 'package:vedem/features/tasks/domain/entities/task_entity.dart';

class TaskModel extends TaskEntity {
  const TaskModel({
    required super.taskId,
    required super.categoryId,
    required super.content,
    required super.isRecurring,
    required super.diamonds,
    required super.isDone,
  });

  @override
  TaskModel copyWith({
    int? taskId,
    int? categoryId,
    String? content,
    bool? isRecurring,
    int? diamonds,
    bool? isDone,
  }) {
    return TaskModel(
      taskId: taskId ?? this.taskId,
      categoryId: categoryId ?? this.categoryId,
      content: content ?? this.content,
      isRecurring: isRecurring ?? this.isRecurring,
      diamonds: diamonds ?? this.diamonds,
      isDone: isDone ?? this.isDone,
    );
  }

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      taskId: (map[TasksKeys.id] ?? 0) as int,
      categoryId: (map[TasksKeys.categoryId] ?? 0) as int,
      content: (map[TasksKeys.content] ?? '') as String,
      isRecurring: ((map[TasksKeys.isRecurring] ?? 0) as int) == 1,
      diamonds: (map[TasksKeys.diamonds] ?? 0) as int,
      isDone: ((map[DayTasksKeys.done] ?? 0) as int) == 1,
    );
  }
  
  TaskEntity toEntity() => TaskEntity(
    taskId: taskId,
    categoryId: categoryId,
    content: content,
    isRecurring: isRecurring,
    diamonds: diamonds,
    isDone: isDone,
  );
}
