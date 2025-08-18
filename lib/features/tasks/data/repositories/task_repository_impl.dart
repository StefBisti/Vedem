import 'package:fpdart/fpdart.dart';
import 'package:vedem/core/error/failures.dart';
import 'package:vedem/features/tasks/domain/entities/task_entity.dart';
import 'package:vedem/features/tasks/domain/repositories/task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  @override
  Future<Either<Failure, TaskEntity>> createNewTask(String dayId, int categoryId, String content, bool isRecurring, int diamonds) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, TaskEntity>> deleteTask(String dayId, int taskId) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<TaskEntity>>> getDefaultTasks(String dayId) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<TaskEntity>>> readTasksForDay(String dayId) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, TaskEntity>> setTask(String dayId, int taskId, bool completed) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, TaskEntity>> updateTask(int taskId, int categoryId, String content, int diamonds, bool isRecurring) {
    throw UnimplementedError();
  }
}