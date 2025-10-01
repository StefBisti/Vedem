import 'package:fpdart/fpdart.dart';
import 'package:vedem/core/error/exceptions.dart';
import 'package:vedem/core/error/failures.dart';
import 'package:vedem/features/tasks/data/datasources/task_data_source.dart';
import 'package:vedem/features/tasks/data/models/day_task_entry_model.dart';
import 'package:vedem/features/tasks/data/models/task_entry_model.dart';
import 'package:vedem/features/tasks/data/models/user_task_model.dart';
import 'package:vedem/features/tasks/domain/entities/subtask_entity.dart';
import 'package:vedem/features/tasks/domain/entities/task_done_type.dart';
import 'package:vedem/features/tasks/domain/entities/task_entity.dart';
import 'package:vedem/features/tasks/domain/entities/task_filter_type.dart';
import 'package:vedem/features/tasks/domain/repository/tasks_repository.dart';

class TaskRepositoryImpl implements TasksRepository {
  final TaskDataSource dataSource;

  const TaskRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, List<TaskEntity>>> getTasksForDay(
    String dayId,
    bool alsoInitialize,
  ) async {
    try {
      if (alsoInitialize) {
        List<UserTaskModel> initializationTasks = await dataSource
            .readDailyOrNotDoneUserTasksFromDay(dayId);

        List<DayTaskEntryModel> initializationDayTasks = initializationTasks
            .map(
              (t) => t.dayTaskEntryModel.copyWith(
                isSecondChance: t.taskEntryModel.isDailyTask == 1 ? 0 : 1,
              ),
            )
            .toList();
        await dataSource.writeDayTaskEntries(initializationDayTasks);
      }
      final List<UserTaskModel> result = await dataSource.readUserTasksByDay(
        dayId,
      );
      return right(result.map((t) => t.toEntity()).toList());
    } on LocalDatabaseException catch (e) {
      return left(LocalDatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<TaskEntity>>> getFilteredTasks(
    TaskFilterType filterType,
  ) async {
    try {
      late List<TaskEntryModel> filteredTasks;
      if (filterType == TaskFilterType.none) {
        filteredTasks = await dataSource.readAllTaskEntries();
      }
      if (filterType == TaskFilterType.byStarred) {
        filteredTasks = await dataSource.readStarredTaskEntries();
      }
      if (filterType == TaskFilterType.byTrashed) {
        filteredTasks = await dataSource.readTrashedTaskEntries();
      } else {
        filteredTasks = await dataSource.readTaskEntriesByCategoryId(
          filterType.index - TaskFilterType.byCategory0.index,
        );
      }
      return right(filteredTasks.map((t) => t.toEntity()).toList());
    } on LocalDatabaseException catch (e) {
      return left(LocalDatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, TaskEntity>> addNewTask(
    String dayId,
    TaskEntity dirtyTask,
  ) async {
    try {
      TaskEntryModel? overlappingTask = await dataSource
          .readTaskEntryWithContent(dirtyTask.content);
      if (overlappingTask != null) {
        TaskEntryModel newTaskEntry = TaskEntryModel.fromEntity(
          dirtyTask,
        ).copyWith(taskId: overlappingTask.taskId);
        await dataSource.updateTaskEntry(newTaskEntry);

        DayTaskEntryModel newDayTaskEntry = DayTaskEntryModel.fromEntity(
          dirtyTask,
        ).copyWith(taskId: overlappingTask.taskId, dayId: dayId);
        await dataSource.writeDayTaskEntry(newDayTaskEntry);
        return right(
          UserTaskModel(
            taskEntryModel: newTaskEntry,
            dayTaskEntryModel: newDayTaskEntry,
          ).toEntity(),
        );
      } else {
        TaskEntryModel newTaskEntry = TaskEntryModel.fromEntity(dirtyTask);
        DayTaskEntryModel newDayTaskEntry = DayTaskEntryModel.fromEntity(
          dirtyTask,
        ).copyWith(dayId: dayId);
        final UserTaskModel result = await dataSource.writeTaskWithDayTask(
          newTaskEntry,
          newDayTaskEntry,
        );
        return right(result.toEntity());
      }
    } on LocalDatabaseException catch (e) {
      return left(LocalDatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateTaskForDay(TaskEntity newTask) async {
    try {
      TaskEntryModel newTaskEntry = TaskEntryModel.fromEntity(newTask);
      DayTaskEntryModel newDayTaskEntry = DayTaskEntryModel.fromEntity(newTask);
      await dataSource.updateTaskAndDayTaskEntry(newTaskEntry, newDayTaskEntry);
      return right(unit);
    } on LocalDatabaseException catch (e) {
      return left(LocalDatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateTask(TaskEntity newTask) async {
    try {
      TaskEntryModel newTaskEntry = TaskEntryModel.fromEntity(newTask);
      await dataSource.updateTaskEntry(newTaskEntry);
      return right(unit);
    } on LocalDatabaseException catch (e) {
      return left(LocalDatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteTaskForDay(int dayTaskId) async {
    try {
      await dataSource.deleteDayTaskEntry(dayTaskId);
      return right(unit);
    } on LocalDatabaseException catch (e) {
      return left(LocalDatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteTask(int taskId) async {
    try {
      await dataSource.deleteTaskEntryRecursively(taskId);
      return right(unit);
    } on LocalDatabaseException catch (e) {
      return left(LocalDatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> toggleTask(
    int dayTaskId,
    TaskDoneType doneType,
  ) async {
    try {
      await dataSource.setDayTaskDoneType(dayTaskId, doneType.index);
      return right(unit);
    } on LocalDatabaseException catch (e) {
      return left(LocalDatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> toggleSubtask(
    TaskEntity currentTask,
    int subtaskIndex,
    bool done,
  ) async {
    try {
      List<SubtaskEntity> newSubtasks = List.from(currentTask.subtasks);
      newSubtasks[subtaskIndex] = newSubtasks[subtaskIndex].copyWith(
        completed: done,
      );
      await dataSource.setDayTaskNewSubtaskEcoding(
        currentTask.dayTaskId!,
        SubtaskEntity.encodeSubtasks(newSubtasks),
      );
      return right(unit);
    } on LocalDatabaseException catch (e) {
      return left(LocalDatabaseFailure(e.message));
    }
  }
}
