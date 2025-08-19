import 'package:fpdart/fpdart.dart';
import 'package:vedem/core/error/failures.dart';
import 'package:vedem/core/error/success.dart';
import 'package:vedem/features/tasks/domain/entities/task_entity.dart';

abstract interface class TaskRepository {
  /// returns either created empty TaskEntity if success or failure
  Future<Either<Failure, TaskEntity>> createNewTask(
    String dayId,
    int categoryId,
    String content,
    bool isRecurring,
    int diamonds,
  );

  /// returns either a list of complete TaskEntities based on a dayId or failure <br>
  /// dayId is of type 'YYYY-MM-DD'
  Future<Either<Failure, List<TaskEntity>>> readTasksForDay(String dayId);

  /// updates and returns a task based on its id, or a failure
  Future<Either<Failure, Success>> updateTask(TaskEntity newTask);

  /// sets a task as completed or not in day task table and returns complete TaskEntity or returns failure
  Future<Either<Failure, Success>> setTask(
    String dayId,
    int taskId,
    bool completed,
  );

  /// deletes from day task table and return the tasks or a failure <br>
  Future<Either<Failure, Success>> deleteTask(String dayId, int taskId);

  /// gets recurring tasks or a failure
  Future<Either<Failure, List<TaskEntity>>> getDefaultTasks(String dayId);
}
