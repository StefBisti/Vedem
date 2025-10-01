import 'package:equatable/equatable.dart';
import 'package:vedem/core/database/database_keys.dart';
import 'package:vedem/features/tasks/domain/entities/subtask_entity.dart';
import 'package:vedem/features/tasks/domain/entities/task_entity.dart';
import 'package:vedem/features/tasks/domain/entities/task_type.dart';

class DayTaskEntryModel extends Equatable {
  final int dayTaskId;
  final String dayId;
  final int taskId;
  final int taskDoneType;
  final int isSecondChance;
  final String? encodedSubtasks;
  final int? taskImportance;
  final int? effortRequired;
  final int? timeRequired;
  final int? notGreatDiamonds;
  final int? onPointDiamonds;
  final int? awesomeDiamonds;
  final int? dueTimeInMinutes;
  final int? notifyTimeInMinutes;

  const DayTaskEntryModel({
    required this.dayTaskId,
    required this.dayId,
    required this.taskId,
    required this.taskDoneType,
    required this.isSecondChance,
    required this.encodedSubtasks,
    required this.taskImportance,
    required this.effortRequired,
    required this.timeRequired,
    required this.notGreatDiamonds,
    required this.onPointDiamonds,
    required this.awesomeDiamonds,
    required this.dueTimeInMinutes,
    required this.notifyTimeInMinutes,
  });

  DayTaskEntryModel copyWith({
    int? dayTaskId,
    String? dayId,
    int? taskId,
    int? taskDoneType,
    int? isSecondChance,
    String? encodedSubtasks,
    int? taskImportance,
    int? effortRequired,
    int? timeRequired,
    int? notGreatDiamonds,
    int? onPointDiamonds,
    int? awesomeDiamonds,
    int? dueTimeInMinutes,
    int? notifyTimeInMinutes,
  }) {
    return DayTaskEntryModel(
      dayTaskId: dayTaskId ?? this.dayTaskId,
      dayId: dayId ?? this.dayId,
      taskId: taskId ?? this.taskId,
      taskDoneType: taskDoneType ?? this.taskDoneType,
      isSecondChance: isSecondChance ?? this.isSecondChance,
      encodedSubtasks: encodedSubtasks ?? this.encodedSubtasks,
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

  factory DayTaskEntryModel.fromMap(Map<String, dynamic> map) {
    return DayTaskEntryModel(
      dayTaskId: map[dayTaskIdKey] as int,
      dayId: map[dayTaskDayIdKey] as String,
      taskId: map[dayTaskTaskIdKey] as int,
      taskDoneType: map[dayTaskDoneTypeKey] as int,
      isSecondChance: map[dayTaskIsSecondChanceKey] as int,
      encodedSubtasks: map[dayTaskEncodedSubtasksKey] as String?,
      taskImportance: map[dayTaskImportanceKey] as int?,
      effortRequired: map[dayTaskEffortRequiredKey] as int?,
      timeRequired: map[dayTaskTimeRequiredKey] as int?,
      notGreatDiamonds: map[dayTaskNotGreatDiamondsKey] as int?,
      onPointDiamonds: map[dayTaskOnPointDiamondsKey] as int?,
      awesomeDiamonds: map[dayTaskAwesomeDiamondsKey] as int?,
      dueTimeInMinutes: map[dayTaskDueTimeInMinutesKey] as int?,
      notifyTimeInMinutes: map[dayTaskNotifyTimeInMinutesKey] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (dayTaskId < 0) dayTaskIdKey: dayTaskId,
      if (dayId.isNotEmpty) dayTaskDayIdKey: dayId,
      if (taskId < 0) dayTaskTaskIdKey: taskId,
      if (taskDoneType < 0) dayTaskDoneTypeKey: taskDoneType,
      if (isSecondChance < 0) dayTaskIsSecondChanceKey: isSecondChance,
      dayTaskEncodedSubtasksKey: encodedSubtasks,
      dayTaskImportanceKey: taskImportance,
      dayTaskEffortRequiredKey: effortRequired,
      dayTaskTimeRequiredKey: timeRequired,
      dayTaskNotGreatDiamondsKey: notGreatDiamonds,
      dayTaskOnPointDiamondsKey: onPointDiamonds,
      dayTaskAwesomeDiamondsKey: awesomeDiamonds,
      dayTaskDueTimeInMinutesKey: dueTimeInMinutes,
      dayTaskNotifyTimeInMinutesKey: notifyTimeInMinutes,
    };
  }

  factory DayTaskEntryModel.fromEntity(TaskEntity entity) {
    return DayTaskEntryModel(
      dayTaskId: entity.dayTaskId ?? -1,
      dayId: '',
      taskId: entity.taskId,
      taskDoneType: entity.taskDoneType.index,
      isSecondChance: entity.taskType == TaskType.secondChance ? 1 : 0,
      encodedSubtasks: SubtaskEntity.encodeSubtasks(entity.subtasks),
      taskImportance: entity.taskImportance,
      effortRequired: entity.effortRequired,
      timeRequired: entity.timeRequired,
      notGreatDiamonds: entity.notGreatDiamonds,
      onPointDiamonds: entity.onPointDiamonds,
      awesomeDiamonds: entity.awesomeDiamonds,
      dueTimeInMinutes: entity.dueTimeInMinutes,
      notifyTimeInMinutes: entity.notifyTimeInMinutes,
    );
  }

  @override
  List<Object?> get props => [
    dayTaskId,
    dayId,
    taskId,
    taskDoneType,
    isSecondChance,
    encodedSubtasks,
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
