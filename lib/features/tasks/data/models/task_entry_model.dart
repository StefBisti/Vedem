import 'package:equatable/equatable.dart';
import 'package:vedem/core/database/database_keys.dart';
import 'package:vedem/core/error/error_messages.dart';
import 'package:vedem/core/error/exceptions.dart';
import 'package:vedem/features/tasks/domain/entities/task_entity.dart';
import 'package:vedem/features/tasks/domain/entities/task_type.dart';

class TaskEntryModel extends Equatable {
  final int taskId;
  final int categoryId;
  final String content;
  final int isStarred;
  final int isDailyTask;

  const TaskEntryModel({
    required this.taskId,
    required this.categoryId,
    required this.content,
    required this.isStarred,
    required this.isDailyTask,
  });

  TaskEntryModel copyWith({
    int? taskId,
    int? categoryId,
    String? content,
    int? isStarred,
    int? isDailyTask,
  }) {
    return TaskEntryModel(
      taskId: taskId ?? this.taskId,
      categoryId: categoryId ?? this.categoryId,
      content: content ?? this.content,
      isStarred: isStarred ?? this.isStarred,
      isDailyTask: isDailyTask ?? this.isDailyTask,
    );
  }

  factory TaskEntryModel.fromMap(Map<String, dynamic> map) {
    return TaskEntryModel(
      taskId: map[taskIdKey] as int,
      categoryId: map[taskCategoryIdKey] as int,
      content: map[taskContentKey] as String,
      isStarred: map[taskIsStarredKey] as int,
      isDailyTask: map[taskIsDailyKey] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (taskId < 0) taskIdKey: taskId,
      taskCategoryIdKey: categoryId,
      taskContentKey: content,
      taskIsStarredKey: isStarred,
      taskIsDailyKey: isDailyTask,
    };
  }

  TaskEntity toEntity() {
    if (taskId < 0) {
      throw ModelException(message: genericError);
    }
    return TaskEntity(
      taskId: taskId,
      categoryId: categoryId,
      content: content,
      isStarred: isStarred == 1,
      taskType: isDailyTask == 1 ? TaskType.repeatDaily : TaskType.plain,
    );
  }

  factory TaskEntryModel.fromEntity(TaskEntity entity) {
    return TaskEntryModel(
      taskId: entity.taskId,
      categoryId: entity.categoryId,
      content: entity.content,
      isStarred: entity.isStarred ? 1 : 0,
      isDailyTask: entity.taskType == TaskType.repeatDaily ? 1 : 0,
    );
  }

  @override
  List<Object?> get props => [
    taskId,
    categoryId,
    content,
    isStarred,
    isDailyTask,
  ];
}
