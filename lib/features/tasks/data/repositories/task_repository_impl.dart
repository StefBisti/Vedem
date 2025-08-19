import 'package:fpdart/fpdart.dart';
import 'package:vedem/core/error/exceptions.dart';
import 'package:vedem/core/error/failures.dart';
import 'package:vedem/features/tasks/data/datasources/task_data_source.dart';
import 'package:vedem/features/tasks/data/models/task_model.dart';
import 'package:vedem/features/tasks/domain/entities/task_entity.dart';
import 'package:vedem/features/tasks/domain/repositories/task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskDataSource localDataSource;

  const TaskRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, TaskEntity>> createNewTaskAndAssignToDay(
    String dayId,
    int categoryId,
    String content,
    bool isRecurring,
    int diamonds,
  ) async {
    try {
      TaskModel newTask = await localDataSource.addNewTaskAndAssignToDay(
        dayId,
        categoryId,
        content,
        isRecurring,
        diamonds,
      );
      return right(newTask);
    } on LocalDatabaseException catch (e) {
      return left(LocalDatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> assignTaskToDay(String dayId, int taskId) async {
    try {
      await localDataSource.addNewDayTaskConnection(
        dayId,
        taskId,
        false,
      );
      return right(unit);
    } on LocalDatabaseException catch (e) {
      return left(LocalDatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<TaskEntity>>> readTasksForDay(
    String dayId,
  ) async {
    try {
      final List<TaskModel> result = await localDataSource.readTasksForDay(
        dayId,
      );
      return right(result);
    } on LocalDatabaseException catch (e) {
      return left(LocalDatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateTask(TaskEntity newTask) async {
    try {
      await localDataSource.updateGenericTask(
        TaskModel(
          taskId: newTask.taskId,
          categoryId: newTask.categoryId,
          content: newTask.content,
          isRecurring: newTask.isRecurring,
          diamonds: newTask.diamonds,
          isDone: newTask.isDone,
        ),
      );
      return right(unit);
    } on LocalDatabaseException catch (e) {
      return left(LocalDatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> setTask(
    String dayId,
    int taskId,
    bool done,
  ) async {
    try {
      await localDataSource.updateDayTaskConnection(dayId, taskId, done);
      return right(unit);
    } on LocalDatabaseException catch (e) {
      return left(LocalDatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteTask(String dayId, int taskId) async {
    try {
      await localDataSource.deleteDayTaskConnection(dayId, taskId);
      return right(unit);
    } on LocalDatabaseException catch (e) {
      return left(LocalDatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<TaskEntity>>> getDefaultTasksNotAssignedToDay(
    String dayId,
  ) async {
    try {
      final List<TaskModel> result = await localDataSource.getDefaultTasksNotAssignedToDay(
        dayId,
      );
      return right(result);
    } on LocalDatabaseException catch (e) {
      return left(LocalDatabaseFailure(e.message));
    }
  }
}
