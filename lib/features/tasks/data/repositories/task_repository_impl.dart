import 'package:fpdart/fpdart.dart';
import 'package:vedem/core/error/exceptions.dart';
import 'package:vedem/core/error/failures.dart';
import 'package:vedem/features/tasks/data/datasources/task_data_source.dart';
import 'package:vedem/features/tasks/data/models/task_model.dart';
import 'package:vedem/features/tasks/domain/entities/task_entity.dart';
import 'package:vedem/features/tasks/domain/repositories/task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskDataSource dataSource;

  const TaskRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, TaskEntity>> createNewTaskAndAssignToDay(
    String dayId,
    int categoryId,
    String content,
    bool isRecurring,
    int diamonds,
  ) async {
    try {
      TaskModel newTask = await dataSource.addNewTaskAndAssignToDay(
        dayId,
        categoryId,
        content,
        isRecurring,
        diamonds,
      );
      return right(newTask.toEntity());
    } on LocalDatabaseException catch (e) {
      return left(LocalDatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<TaskEntity>>> readTasksForDay(
    String dayId,
  ) async {
    try {
      final List<TaskModel> result = await dataSource.readTasksForDay(dayId);
      return right(result.map((t) => t.toEntity()).toList());
    } on LocalDatabaseException catch (e) {
      return left(LocalDatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<TaskEntity>>> readTasksForMonth(
    String monthId,
  ) async {
    try {
      final List<TaskModel> result = await dataSource.readTasksForMonth(
        monthId,
      );
      return right(result.map((t) => t.toEntity()).toList());
    } on LocalDatabaseException catch (e) {
      return left(LocalDatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateTask(
    int taskId,
    int categoryId,
    String content,
    bool isRecurring,
    int diamonds,
  ) async {
    try {
      await dataSource.updateGenericTask(
        taskId,
        categoryId,
        content,
        isRecurring,
        diamonds,
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
      await dataSource.updateDayTaskConnection(dayId, taskId, done);
      return right(unit);
    } on LocalDatabaseException catch (e) {
      return left(LocalDatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteTask(
    String? dayId,
    int taskId,
    bool isRecurring,
  ) async {
    try {
      if (dayId == null) {
        await dataSource.deleteTaskCompletely(taskId);
      } else if (isRecurring == false) {
        await dataSource.deleteDayTaskConnection(dayId, taskId);
      } else {
        await dataSource.deleteDayTaskConnectionAndSetTaskNotRecurring(
          dayId,
          taskId,
        );
      }

      return right(unit);
    } on LocalDatabaseException catch (e) {
      return left(LocalDatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<TaskEntity>>> initializeTasksForDay(
    String dayId,
  ) async {
    try {
      final List<TaskModel> result = await dataSource
          .getDefaultTasksNotAssignedToDay(dayId);
      await Future.wait(
        result.map(
          (task) =>
              dataSource.addNewDayTaskConnection(dayId, task.taskId, false),
        ),
      );
      return right(result.map((t) => t.toEntity()).toList());
    } on LocalDatabaseException catch (e) {
      return left(LocalDatabaseFailure(e.message));
    }
  }
}
