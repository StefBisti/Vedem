import 'package:vedem/core/database/database_keys.dart';
import 'package:vedem/features/tasks/domain/entities/task_entity.dart';

class TaskModel extends TaskEntity {
  const TaskModel({
    required super.taskId,
    required super.categoryId,
    required super.content,
    required super.isRecurring,
    required super.diamonds,
    required super.isDone
  });

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
      taskId: map[taskIdKey] as int,
      categoryId: map[taskCategoryIdKey] as int,
      content: map[taskContentKey] as String,
      isRecurring: (map[taskIsRecurringKey] as int) == 1,
      diamonds: map[taskDiamondsKey] as int,
      isDone: map.containsKey(dayTaskDoneKey) ? (map[dayTaskDoneKey] as int) == 1 : false,
    );
  }
}
