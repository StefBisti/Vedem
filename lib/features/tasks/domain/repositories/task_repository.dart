import 'package:fpdart/fpdart.dart';
import 'package:vedem/core/error/failures.dart';
import 'package:vedem/features/tasks/domain/entities/task_entity.dart';

abstract interface class TaskRepository {
  /// returns the created TaskEntity with taskId and assignes to to day
  Future<Either<Failure, TaskEntity>> createNewTaskAndAssignToDay(
    String dayId,
    int categoryId,
    String content,
    bool isRecurring,
    int diamonds,
  );

  /// assigns an existing task to a day
  Future<Either<Failure, Unit>> assignTaskToDay(String dayId, int taskId);

  /// returns either a list of TaskEntities with ids assigned to a day
  Future<Either<Failure, List<TaskEntity>>> readTasksForDay(String dayId);

  /// updates a task based on its id
  Future<Either<Failure, Unit>> updateTask(TaskEntity newTask);

  /// sets a task as completed or not in dayTask table
  Future<Either<Failure, Unit>> setTask(
    String dayId,
    int taskId,
    bool completed,
  );

  /// deletes from dayTask table the task with taskId assigned to the day with dayId
  Future<Either<Failure, Unit>> deleteTask(String dayId, int taskId);

  /// gets recurring tasks or second chance tasks for a day
  Future<Either<Failure, List<TaskEntity>>> getDefaultTasksNotAssignedToDay(String dayId);
}
