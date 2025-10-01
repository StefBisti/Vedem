import 'package:fpdart/fpdart.dart';
import 'package:vedem/core/error/failures.dart';
import 'package:vedem/features/tasks/domain/entities/task_done_type.dart';
import 'package:vedem/features/tasks/domain/entities/task_entity.dart';
import 'package:vedem/features/tasks/domain/entities/task_filter_type.dart';

abstract interface class TasksRepository {
  Future<Either<Failure, List<TaskEntity>>> getTasksForDay(
    String dayId,
    bool alsoInitialize,
  );

  Future<Either<Failure, List<TaskEntity>>> getFilteredTasks(
    TaskFilterType filterType,
  );

  Future<Either<Failure, TaskEntity>> addNewTask(
    String dayId,
    TaskEntity dirtyTask,
  );

  Future<Either<Failure, Unit>> updateTaskForDay(
    TaskEntity newTask,
  );

  Future<Either<Failure, Unit>> updateTask(TaskEntity newTask);

  Future<Either<Failure, Unit>> deleteTaskForDay(int dayTaskId);

  Future<Either<Failure, Unit>> deleteTask(int taskId);

  Future<Either<Failure, Unit>> toggleTask(
    int dayTaskId,
    TaskDoneType doneType,
  );

  Future<Either<Failure, Unit>> toggleSubtask(
    TaskEntity currentTask,
    int subtaskIndex,
    bool done,
  );
}
