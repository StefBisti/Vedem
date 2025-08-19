import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite/sqflite.dart';
import 'package:vedem/core/database/database_keys.dart';
import 'package:vedem/core/error/error_messages.dart';
import 'package:vedem/core/error/exceptions.dart';
import 'package:vedem/features/tasks/data/datasources/task_local_data_source.dart';
import 'package:vedem/features/tasks/data/models/task_model.dart';

class MockDatabase extends Mock implements Database {}

void main() {
  late MockDatabase db;
  late TaskLocalDataSource dataSource;

  setUp(() {
    db = MockDatabase();
    dataSource = TaskLocalDataSource(db: db);
  });

  const String sampleDay = '2025-08-18';
  const TaskModel sampleTaskModel = TaskModel(
    taskId: 44,
    categoryId: 1,
    content: 'test content',
    isRecurring: true,
    diamonds: 232,
    isDone: false,
  );
  final TaskModel sampleUpdated = TaskModel(
    taskId: 44,
    categoryId: 1,
    content: 'updated test content',
    isRecurring: true,
    diamonds: 232,
    isDone: false,
  );
  final sampleRow = <String, Object?>{
    taskIdKey: 44,
    taskCategoryIdKey: 1,
    taskContentKey: 'test content',
    taskIsRecurringKey: 1,
    taskDiamondsKey: 232,
    dayTaskDoneKey: 0,
  };

  test(
    'addNewGenericTask returns created task model with correct taskID',
    () async {
      when(() => db.insert(any(), any())).thenAnswer((_) async => 44);
      final result = await dataSource.addNewGenericTask(
        1,
        'test content',
        true,
        232,
      );
      expect(result, sampleTaskModel);
      verify(() => db.insert(tasksTableKey, any())).called(1);
    },
  );
  test(
    'addNewGenericTask throws [LocalDatabaseException] with addTaskError',
    () async {
      when(
        () => db.insert(any(), any()),
      ).thenThrow(LocalDatabaseException(message: addTaskError));
      expect(
        () async =>
            await dataSource.addNewGenericTask(1, 'test content', true, 232),
        throwsA(LocalDatabaseException(message: addTaskError)),
      );
      verify(() => db.insert(tasksTableKey, any())).called(1);
    },
  );

  test('addNewDayTaskConnection calls insert on dayTasks table', () async {
    when(() => db.insert(any(), any())).thenAnswer((_) async => 44);
    await dataSource.addNewDayTaskConnection(sampleDay, 7, 0);
    verify(() => db.insert(dayTasksTableKey, any())).called(1);
  });
  test(
    'addNewDayTaskConnection throws [LocalDatabaseException] with addTaskError',
    () async {
      when(
        () => db.insert(any(), any()),
      ).thenThrow(LocalDatabaseException(message: addTaskError));
      expect(
        () async => await dataSource.addNewDayTaskConnection(sampleDay, 7, 0),
        throwsA(LocalDatabaseException(message: addTaskError)),
      );
      verify(() => db.insert(dayTasksTableKey, any())).called(1);
    },
  );

  test('readTasksForDay returns mapped TaskModel list', () async {
    when(() => db.rawQuery(any(), any())).thenAnswer((_) async => [sampleRow]);
    final list = await dataSource.readTasksForDay(sampleDay);
    expect(list[0], sampleTaskModel);
    verify(() => db.rawQuery(any(), any())).called(1);
  });
  test('readTasksForDay throws LocalDatabaseException on DB error', () async {
    when(
      () => db.rawQuery(any()),
    ).thenThrow(LocalDatabaseException(message: readTasksError));
    expect(
      () => dataSource.readTasksForDay(sampleDay),
      throwsA(LocalDatabaseException(message: readTasksError)),
    );
    verify(() => db.rawQuery(any(), any())).called(1);
  });

  test('getDefaultTasks returns recurring tasks list', () async {
    when(() => db.rawQuery(any())).thenAnswer((_) async => [sampleRow]);
    final list = await dataSource.getDefaultTasks(sampleDay);
    expect(list[0], sampleTaskModel);
    verify(() => db.rawQuery(any())).called(1);
  });
  test('getDefaultTasks throws LocalDatabaseException on DB error', () async {
    when(
      () => db.rawQuery(any()),
    ).thenThrow(LocalDatabaseException(message: readTasksError));
    expect(
      () => dataSource.getDefaultTasks(sampleDay),
      throwsA(LocalDatabaseException(message: readTasksError)),
    );
    verify(() => db.rawQuery(any())).called(1);
  });

  test('updateGenericTask calls db.update with proper where clause', () async {
    when(
      () => db.update(
        any(),
        any(),
        where: any(named: 'where'),
        whereArgs: any(named: 'whereArgs'),
      ),
    ).thenAnswer((_) async => 1);

    await dataSource.updateGenericTask(sampleUpdated);

    verify(
      () => db.update(
        tasksTableKey,
        any(),
        where: '$taskIdKey = ?',
        whereArgs: [sampleUpdated.taskId],
      ),
    ).called(1);
  });

  test('updateGenericTask throws LocalDatabaseException on DB error', () async {
    when(
      () => db.update(
        any(),
        any(),
        where: any(named: 'where'),
        whereArgs: any(named: 'whereArgs'),
      ),
    ).thenThrow(Exception());
    expect(
      () => dataSource.updateGenericTask(sampleUpdated),
      throwsA(isA<LocalDatabaseException>()),
    );
    verify(
      () => db.update(
        tasksTableKey,
        any(),
        where: any(named: 'where'),
        whereArgs: any(named: 'whereArgs'),
      ),
    ).called(1);
  });

  test('deleteGenericTask calls db.delete', () async {
    when(
      () => db.delete(
        any(),
        where: any(named: 'where'),
        whereArgs: any(named: 'whereArgs'),
      ),
    ).thenAnswer((_) async => 1);

    await dataSource.deleteGenericTask(9);
    verify(
      () => db.delete(tasksTableKey, where: '$taskIdKey = ?', whereArgs: [9]),
    ).called(1);
  });

  test('deleteDayTaskConnection calls db.delete', () async {
    when(
      () => db.delete(
        any(),
        where: any(named: 'where'),
        whereArgs: any(named: 'whereArgs'),
      ),
    ).thenAnswer((_) async => 1);
    await dataSource.deleteDayTaskConnection(sampleDay, 9);
    verify(
      () => db.delete(
        dayTasksTableKey,
        where: '$dayTaskDayKey = ? AND $dayTaskTaskKey = ?',
        whereArgs: [sampleDay, 9],
      ),
    ).called(1);
  });

  test(
    'deleteDayTaskConnection throws LocalDatabaseException on DB error',
    () async {
      when(
        () => db.delete(
          any(),
          where: any(named: 'where'),
          whereArgs: any(named: 'whereArgs'),
        ),
      ).thenThrow(Exception());
      expect(
        () => dataSource.deleteDayTaskConnection(sampleDay, 9),
        throwsA(isA<LocalDatabaseException>()),
      );
      verify(
        () => db.delete(
          dayTasksTableKey,
          where: any(named: 'where'),
          whereArgs: any(named: 'whereArgs'),
        ),
      ).called(1);
    },
  );
}
