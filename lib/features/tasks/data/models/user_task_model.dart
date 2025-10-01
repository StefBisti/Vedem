import 'package:equatable/equatable.dart';
import 'package:vedem/core/error/error_messages.dart';
import 'package:vedem/core/error/exceptions.dart';
import 'package:vedem/features/tasks/data/models/day_task_entry_model.dart';
import 'package:vedem/features/tasks/data/models/task_entry_model.dart';
import 'package:vedem/features/tasks/domain/entities/subtask_entity.dart';
import 'package:vedem/features/tasks/domain/entities/task_done_type.dart';
import 'package:vedem/features/tasks/domain/entities/task_entity.dart';
import 'package:vedem/features/tasks/domain/entities/task_type.dart';

class UserTaskModel extends Equatable {
  final TaskEntryModel taskEntryModel;
  final DayTaskEntryModel dayTaskEntryModel;

  const UserTaskModel({
    required this.taskEntryModel,
    required this.dayTaskEntryModel,
  });

  UserTaskModel copyWith({
    TaskEntryModel? taskEntryModel,
    DayTaskEntryModel? dayTaskEntryModel,
  }) {
    return UserTaskModel(
      taskEntryModel: taskEntryModel ?? this.taskEntryModel,
      dayTaskEntryModel: dayTaskEntryModel ?? this.dayTaskEntryModel,
    );
  }

  TaskEntity toEntity() {
    if (taskEntryModel.taskId < 0) {
      throw ModelException(message: genericError);
    }
    return TaskEntity(
      taskId: taskEntryModel.taskId,
      categoryId: taskEntryModel.categoryId,
      content: taskEntryModel.content,
      isStarred: taskEntryModel.isStarred == 1,
      taskType: taskEntryModel.isDailyTask == 1
          ? TaskType.repeatDaily
          : dayTaskEntryModel.isSecondChance == 1
          ? TaskType.secondChance
          : TaskType.plain,
      dayTaskId: dayTaskEntryModel.dayTaskId,
      taskDoneType: TaskDoneType.values[dayTaskEntryModel.taskDoneType],
      subtasks: SubtaskEntity.decodeSubtasks(
        dayTaskEntryModel.encodedSubtasks ?? '',
      ),
      taskImportance: dayTaskEntryModel.taskImportance,
      effortRequired: dayTaskEntryModel.effortRequired,
      timeRequired: dayTaskEntryModel.timeRequired,
      notGreatDiamonds: dayTaskEntryModel.notGreatDiamonds,
      onPointDiamonds: dayTaskEntryModel.onPointDiamonds,
      awesomeDiamonds: dayTaskEntryModel.awesomeDiamonds,
      dueTimeInMinutes: dayTaskEntryModel.dueTimeInMinutes,
      notifyTimeInMinutes: dayTaskEntryModel.notifyTimeInMinutes,
    );
  }

  @override
  List<Object?> get props => [taskEntryModel, dayTaskEntryModel];
}
