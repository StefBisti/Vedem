import 'package:equatable/equatable.dart';
import 'package:vedem/features/tasks/domain/entities/subtask_entity.dart';
import 'package:vedem/features/tasks/domain/entities/task_done_type.dart';
import 'package:vedem/features/tasks/domain/entities/task_type.dart';

class TaskEntity extends Equatable {
  final int taskId;
  final int categoryId;
  final String content;
  final bool isStarred;
  final TaskType taskType;
  final int? dayTaskId;
  final TaskDoneType taskDoneType;
  final List<SubtaskEntity> subtasks;
  final int? taskImportance;
  final int? effortRequired;
  final int? timeRequired;
  final int? notGreatDiamonds;
  final int? onPointDiamonds;
  final int? awesomeDiamonds;
  final int? dueTimeInMinutes;
  final int? notifyTimeInMinutes;

  const TaskEntity({
    required this.taskId,
    required this.categoryId,
    required this.content,
    this.isStarred = false,
    this.taskType = TaskType.plain,
    this.dayTaskId,
    this.taskDoneType = TaskDoneType.notDone,
    this.subtasks = const [],
    this.taskImportance,
    this.effortRequired,
    this.timeRequired,
    this.notGreatDiamonds,
    this.onPointDiamonds,
    this.awesomeDiamonds,
    this.dueTimeInMinutes,
    this.notifyTimeInMinutes,
  });

  TaskEntity copyWith({
    int? taskId,
    int? categoryId,
    String? content,
    bool? isStarred,
    TaskType? taskType,
    int? dayTaskId,
    TaskDoneType? taskDoneType,
    List<SubtaskEntity>? subtasks,
    int? taskImportance,
    int? effortRequired,
    int? timeRequired,
    int? notGreatDiamonds,
    int? onPointDiamonds,
    int? awesomeDiamonds,
    int? dueTimeInMinutes,
    int? notifyTimeInMinutes,
  }) {
    return TaskEntity(
      taskId: taskId ?? this.taskId,
      categoryId: categoryId ?? this.categoryId,
      content: content ?? this.content,
      isStarred: isStarred ?? this.isStarred,
      taskType: taskType ?? this.taskType,
      dayTaskId: dayTaskId ?? this.dayTaskId,
      taskDoneType: taskDoneType ?? this.taskDoneType,
      subtasks: subtasks ?? this.subtasks,
      taskImportance: taskImportance ?? this.taskImportance,
      effortRequired: effortRequired ?? this.effortRequired,
      timeRequired: timeRequired ?? this.timeRequired,
      notGreatDiamonds: notGreatDiamonds ?? this.notGreatDiamonds,
      onPointDiamonds: onPointDiamonds ?? this.onPointDiamonds,
      awesomeDiamonds: awesomeDiamonds ?? this.awesomeDiamonds,
      dueTimeInMinutes: dueTimeInMinutes ?? this.dueTimeInMinutes,
      notifyTimeInMinutes: notifyTimeInMinutes ?? this.notifyTimeInMinutes,
    );
  }

  static List<TaskEntity> copyList(List<TaskEntity> previousTasks) {
    List<TaskEntity> newTasks = List.from(previousTasks);
    for (int i = 0; i < newTasks.length; i++) {
      newTasks[i] = newTasks[i].copyWith(
        subtasks: List.from(newTasks[i].subtasks),
      );
    }
    return newTasks;
  }

  static TaskEntity copyTask(TaskEntity task) {
    return task.copyWith(subtasks: List.from(task.subtasks));
  }

  int getDiamonds(TaskDoneType doneType) {
    if (onPointDiamonds == null) return 0;
    if (doneType == TaskDoneType.notGreat) {
      return notGreatDiamonds!;
    } else if (doneType == TaskDoneType.onPoint) {
      return onPointDiamonds!;
    } else if (doneType == TaskDoneType.awesome) {
      return awesomeDiamonds!;
    } else {
      return onPointDiamonds!;
    }
  }

  @override
  List<Object?> get props => [
    taskId,
    categoryId,
    content,
    isStarred,
    taskType,
    dayTaskId,
    taskDoneType,
    subtasks,
    taskImportance,
    effortRequired,
    timeRequired,
    notGreatDiamonds,
    onPointDiamonds,
    awesomeDiamonds,
    dueTimeInMinutes,
    notifyTimeInMinutes,
  ];
}
