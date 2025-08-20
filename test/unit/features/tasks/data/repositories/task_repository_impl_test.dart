import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vedem/core/error/error_messages.dart';
import 'package:vedem/core/error/exceptions.dart';
import 'package:vedem/core/error/failures.dart';
import 'package:vedem/features/tasks/data/datasources/task_data_source.dart';
import 'package:vedem/features/tasks/data/models/task_model.dart';
import 'package:vedem/features/tasks/data/repositories/task_repository_impl.dart';
import 'package:vedem/features/tasks/domain/repositories/task_repository.dart';

class MockDataSource extends Mock implements TaskDataSource {}

void main() {
  late TaskRepository repo;
  late MockDataSource dataSource;

  final TaskModel sampleTaskModel = TaskModel(
    taskId: 54,
    categoryId: 1,
    content: 'test',
    isRecurring: true,
    diamonds: 34,
    isDone: false,
  );
  final String sampleDay = '2025-08-18';

  setUp(() {
    dataSource = MockDataSource();
    repo = TaskRepositoryImpl(dataSource: dataSource);
  });

  ////////////////// createNewTaskAndAssignToDay //////////////////
  test(
    'createNewTaskAndAssignToDay should return newly created task',
    () async {
      when(
        () => dataSource.addNewTaskAndAssignToDay(
          any(),
          any(),
          any(),
          any(),
          any(),
        ),
      ).thenAnswer((_) async => sampleTaskModel);
      final res = await repo.createNewTaskAndAssignToDay(
        sampleDay,
        1,
        'test',
        true,
        34,
      );
      expect(res, right(sampleTaskModel));
    },
  );
  test(
    'createNewTaskAndAssignToDay should return failure on exception',
    () async {
      when(
        () => dataSource.addNewTaskAndAssignToDay(
          any(),
          any(),
          any(),
          any(),
          any(),
        ),
      ).thenThrow(LocalDatabaseException(message: addTaskError));
      final res = await repo.createNewTaskAndAssignToDay(
        sampleDay,
        1,
        'test',
        true,
        34,
      );
      expect(res, left(LocalDatabaseFailure(addTaskError)));
    },
  );

  ////////////////// assignTaskToDay //////////////////
  test('assignTaskToDay should return Unit when done', () async {
    when(
      () => dataSource.addNewDayTaskConnection(any(), any(), any()),
    ).thenAnswer((_) async {});
    final res = await repo.assignTaskToDay(sampleDay, 54);
    expect(res, right(unit));
  });
  test('assignTaskToDay should return failure on exception', () async {
    when(
      () => dataSource.addNewDayTaskConnection(any(), any(), any()),
    ).thenThrow(LocalDatabaseException(message: addTaskError));
    final res = await repo.assignTaskToDay(sampleDay, 54);
    expect(res, left(LocalDatabaseFailure(addTaskError)));
  });

  ////////////////// readTasksForDay //////////////////
  test('readTasksForDay should return task entities when done', () async {
    final returnList = [sampleTaskModel];
    when(
      () => dataSource.readTasksForDay(any()),
    ).thenAnswer((_) async => returnList);
    final res = await repo.readTasksForDay(sampleDay);
    expect(res, right(returnList));
  });
  test('readTasksForDay should return failure on exception', () async {
    when(
      () => dataSource.readTasksForDay(any()),
    ).thenThrow(LocalDatabaseException(message: readTasksError));
    final res = await repo.readTasksForDay(sampleDay);
    expect(res, left(LocalDatabaseFailure(readTasksError)));
  });

  ////////////////// updateTask //////////////////
  test('updateTask should return unit on success', () async {
    when(
      () => dataSource.updateGenericTask(any(), any(), any(), any(), any()),
    ).thenAnswer((_) async {});
    final res = await repo.updateTask(54, 1, 'test', true, 34);
    expect(res, right(unit));
  });
  test('updateTask should return failure on exception', () async {
    when(
      () => dataSource.updateGenericTask(any(), any(), any(), any(), any()),
    ).thenThrow(LocalDatabaseException(message: updateTaskError));
    final res = await repo.updateTask(54, 1, 'test', true, 34);
    expect(res, left(LocalDatabaseFailure(updateTaskError)));
  });

  ////////////////// setTask //////////////////
  test('setTask should return unit', () async {
    when(
      () => dataSource.updateDayTaskConnection(any(), any(), any()),
    ).thenAnswer((_) async => sampleTaskModel);
    final res = await repo.setTask(sampleDay, 54, true);
    expect(res, right(unit));
  });
  test('setTask should return failure on exception', () async {
    when(
      () => dataSource.updateDayTaskConnection(any(), any(), any()),
    ).thenThrow(LocalDatabaseException(message: updateTaskError));
    final res = await repo.setTask(sampleDay, 54, true);
    expect(res, left(LocalDatabaseFailure(updateTaskError)));
  });

  ////////////////// deleteTask //////////////////
  test('deleteTask should return unit on success when dayId == null', () async {
    when(() => dataSource.deleteTaskCompletely(any())).thenAnswer((_) async {});
    final res = await repo.deleteTask(null, 54, true);
    expect(res, right(unit));
  });
  test(
    'deleteTask should return unit on success when isRecurring == false',
    () async {
      when(
        () => dataSource.deleteDayTaskConnection(any(), any()),
      ).thenAnswer((_) async {});
      final res = await repo.deleteTask(sampleDay, 54, false);
      expect(res, right(unit));
    },
  );
  test('deleteTask should return unit on success when else', () async {
    when(
      () => dataSource.deleteDayTaskConnectionAndSetTaskNotRecurring(
        any(),
        any(),
      ),
    ).thenAnswer((_) async {});
    final res = await repo.deleteTask(sampleDay, 54, true);
    expect(res, right(unit));
  });
  test('deleteTask should return failure on exception', () async {
    when(
      () => dataSource.deleteTaskCompletely(any()),
    ).thenThrow(LocalDatabaseException(message: deleteTaskError));
    final res = await repo.deleteTask(null, 54, true);
    expect(res, left(LocalDatabaseFailure(deleteTaskError)));
  });

  ////////////////// setTask //////////////////
  test('getDefaultTasksNotAssignedToDay should return tasks', () async {
    final returnList = [sampleTaskModel];
    when(
      () => dataSource.getDefaultTasksNotAssignedToDay(any()),
    ).thenAnswer((_) async => returnList);
    final res = await repo.getDefaultTasksNotAssignedToDay(sampleDay);
    expect(res, right(returnList));
  });
  test('getDefaultTasksNotAssignedToDay should return failure on exception', () async {
    when(
      () => dataSource.getDefaultTasksNotAssignedToDay(any()),
    ).thenThrow(LocalDatabaseException(message: readTasksError));
    final res = await repo.getDefaultTasksNotAssignedToDay(sampleDay);
    expect(res, left(LocalDatabaseFailure(readTasksError)));
  });
}
