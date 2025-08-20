import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vedem/core/database/database_keys.dart';
import 'package:vedem/core/error/exceptions.dart';
import 'package:vedem/features/tasks/data/datasources/task_local_data_source.dart';
import 'package:vedem/features/tasks/data/models/task_model.dart';

class MockDatabase extends Mock implements Database {}

class MockTransaction extends Mock implements Transaction {}

void main() {
  late MockDatabase db;
  late MockTransaction txn;
  late TaskLocalDataSource dataSource;

  final TaskModel sampleTask = TaskModel(
    taskId: 54,
    categoryId: 1,
    content: 'test',
    isRecurring: true,
    diamonds: 34,
    isDone: false,
  );
  final String sampleDay = '2025-08-18';
  final sampleDbRow = {
    TasksTableKeys.taskIdKey: 54,
    TasksTableKeys.taskCategoryIdKey: 1,
    TasksTableKeys.taskContentKey: 'test',
    TasksTableKeys.taskIsRecurringKey: 1,
    TasksTableKeys.taskDiamondsKey: 34,
    DayTasksTableKeys.dayTaskDoneKey: 0,
  };

  setUp(() {
    db = MockDatabase();
    txn = MockTransaction();
    dataSource = TaskLocalDataSource(db: db);
  });

  ////////////////// addNewTaskAndAssignToDay //////////////////
  test(
    'addNewTaskAndAssignToDay should insert into tasks and dayTasks when success',
    () async {
      when(
        () => txn.insert(TasksTableKeys.tasksTableKey, any()),
      ).thenAnswer((_) async => 54);
      when(
        () => txn.insert(DayTasksTableKeys.dayTasksTableKey, any()),
      ).thenAnswer((_) async => 1001);
      when(() => db.transaction<TaskModel>(any())).thenAnswer((inv) {
        final callback =
            inv.positionalArguments[0]
                as Future<TaskModel> Function(Transaction txn);
        return callback(txn);
      });

      final res = await dataSource.addNewTaskAndAssignToDay(
        sampleDay,
        1,
        'test',
        true,
        34,
      );

      expect(res, sampleTask);
      verify(
        () => txn.insert(TasksTableKeys.tasksTableKey, {
          TasksTableKeys.taskCategoryIdKey: 1,
          TasksTableKeys.taskContentKey: 'test',
          TasksTableKeys.taskIsRecurringKey: 1,
          TasksTableKeys.taskDiamondsKey: 34,
        }),
      ).called(1);
      verify(
        () => txn.insert(DayTasksTableKeys.dayTasksTableKey, {
          DayTasksTableKeys.dayTaskDayKey: sampleDay,
          DayTasksTableKeys.dayTaskTaskKey: 54,
          DayTasksTableKeys.dayTaskDoneKey: 0,
        }),
      ).called(1);

      verifyNoMoreInteractions(txn);
    },
  );
  test(
    'addNewTaskAndAssignToDay throws LocalDatabaseException when transaction throws',
    () async {
      // Make transaction throw
      when(
        () => db.transaction<TaskModel>(any()),
      ).thenThrow(Exception('db gone boom'));

      expect(
        () =>
            dataSource.addNewTaskAndAssignToDay(sampleDay, 1, 'test', true, 34),
        throwsA(isA<LocalDatabaseException>()),
      );
    },
  );

  ////////////////// addNewDayTaskConnection //////////////////
  test(
    'addNewDayTaskConnection should insert into dayTasks table when success',
    () async {
      when(() => db.insert(any(), any())).thenAnswer((_) async => 1001);
      dataSource.addNewDayTaskConnection(
        sampleDay,
        sampleTask.taskId,
        sampleTask.isDone,
      );
      verify(() => db.insert(any(), any())).called(1);
    },
  );
  test(
    'addNewDayTaskConnection throws LocalDatabaseException when database throws',
    () async {
      when(() => db.insert(any(), any())).thenThrow(Exception());
      expect(
        () => dataSource.addNewDayTaskConnection(
          sampleDay,
          sampleTask.taskId,
          sampleTask.isDone,
        ),
        throwsA(isA<LocalDatabaseException>()),
      );
    },
  );

  ////////////////// readTasksForDay //////////////////
  test(
    'readTasksForDay returns a list of TaskModel when query succeeds',
    () async {
      when(
        () => db.rawQuery(any(), any()),
      ).thenAnswer((_) async => [sampleDbRow]);
      final result = await dataSource.readTasksForDay(sampleDay);
      expect(result, hasLength(1));
      expect(result[0], sampleTask);
      verify(
        () => db.rawQuery(any(that: contains('INNER JOIN')), [sampleDay]),
      ).called(1);
    },
  );
  test(
    'readTasksForDay throws LocalDatabaseException when query fails',
    () async {
      when(() => db.rawQuery(any(), any())).thenThrow(Exception('DB error'));
      expect(
        () => dataSource.readTasksForDay(sampleDay),
        throwsA(isA<LocalDatabaseException>()),
      );
    },
  );

  ////////////////// getDefaultTasksNotAssignedToDay //////////////////
  test(
    'getDefaultTasksNotAssignedToDay returns a list of recurring TaskModels when query succeeds',
    () async {
      when(() => db.rawQuery(any())).thenAnswer((_) async => [sampleDbRow]);
      final result = await dataSource.getDefaultTasksNotAssignedToDay(
        sampleDay,
      );
      expect(result, hasLength(1));
      expect(result[0], sampleTask);
      verify(
        () => db.rawQuery(
          any(that: contains('WHERE ${TasksTableKeys.taskIsRecurringKey} = 1')),
        ),
      ).called(1);
    },
  );
  test(
    'getDefaultTasksNotAssignedToDay throws LocalDatabaseException when query fails',
    () async {
      when(() => db.rawQuery(any())).thenThrow(Exception('DB error'));
      expect(
        () => dataSource.getDefaultTasksNotAssignedToDay(sampleDay),
        throwsA(isA<LocalDatabaseException>()),
      );
    },
  );

  ////////////////// updateGenericTask //////////////////
  test('updateGenericTask calls db.update with the correct values', () async {
    when(
      () => db.update(
        any(),
        any(),
        where: any(named: 'where'),
        whereArgs: any(named: 'whereArgs'),
      ),
    ).thenAnswer((_) async => 1);
    await dataSource.updateGenericTask(54, 1, 'test', true, 34);
    verify(
      () => db.update(
        TasksTableKeys.tasksTableKey,
        {
          TasksTableKeys.taskCategoryIdKey: 1,
          TasksTableKeys.taskContentKey: 'test',
          TasksTableKeys.taskIsRecurringKey: 1,
          TasksTableKeys.taskDiamondsKey: 34,
        },
        where: '${TasksTableKeys.taskIdKey} = ?',
        whereArgs: [54],
      ),
    ).called(1);
  });
  test(
    'updateGenericTask throws LocalDatabaseException when db.update throws',
    () async {
      when(
        () => db.update(
          any(),
          any(),
          where: any(named: 'where'),
          whereArgs: any(named: 'whereArgs'),
        ),
      ).thenThrow(Exception('db error'));
      expect(
        () => dataSource.updateGenericTask(54, 1, 'test', true, 34),
        throwsA(isA<LocalDatabaseException>()),
      );
    },
  );

  ////////////////// updateDayTaskConnection //////////////////
  test(
    'updateDayTaskConnection calls db.update with the correct values',
    () async {
      when(
        () => db.update(
          any(),
          any(),
          where: any(named: 'where'),
          whereArgs: any(named: 'whereArgs'),
        ),
      ).thenAnswer((_) async => 1);
      await dataSource.updateDayTaskConnection(sampleDay, 54, true);
      verify(
        () => db.update(
          DayTasksTableKeys.dayTasksTableKey,
          {DayTasksTableKeys.dayTaskDoneKey: 1},
          where:
              '${DayTasksTableKeys.dayTaskDayKey} = ? AND ${DayTasksTableKeys.dayTaskTaskKey} = ?',
          whereArgs: [sampleDay, 54],
        ),
      ).called(1);
    },
  );
  test(
    'updateDayTaskConnection throws LocalDatabaseException when db.update throws',
    () async {
      when(
        () => db.update(
          any(),
          any(),
          where: any(named: 'where'),
          whereArgs: any(named: 'whereArgs'),
        ),
      ).thenThrow(Exception('db error'));
      expect(
        () => dataSource.updateDayTaskConnection(sampleDay, 54, true),
        throwsA(isA<LocalDatabaseException>()),
      );
    },
  );

  ////////////////// deleteTaskCompletely //////////////////
  test(
    'deleteTaskCompletely deletes task from both tables successfully',
    () async {
      when(() => db.transaction<void>(any())).thenAnswer((inv) {
        final callback =
            inv.positionalArguments[0] as Future<void> Function(Transaction);

        return callback(txn);
      });

      // Mock the delete operations
      when(
        () => txn.delete(
          TasksTableKeys.tasksTableKey,
          where: '${TasksTableKeys.taskIdKey} = ?',
          whereArgs: [54],
        ),
      ).thenAnswer((_) async => 1);

      when(
        () => txn.delete(
          DayTasksTableKeys.dayTasksTableKey,
          where: '${DayTasksTableKeys.dayTaskTaskKey} = ?',
          whereArgs: [54],
        ),
      ).thenAnswer((_) async => 1);

      await dataSource.deleteTaskCompletely(54);

      verify(
        () => txn.delete(
          TasksTableKeys.tasksTableKey,
          where: '${TasksTableKeys.taskIdKey} = ?',
          whereArgs: [54],
        ),
      ).called(1);

      verify(
        () => txn.delete(
          DayTasksTableKeys.dayTasksTableKey,
          where: '${DayTasksTableKeys.dayTaskTaskKey} = ?',
          whereArgs: [54],
        ),
      ).called(1);
    },
  );

  test(
    'deleteTaskCompletely throws LocalDatabaseException when db.delete throws',
    () async {
      when(
        () => txn.delete(
          any(),
          where: any(named: 'where'),
          whereArgs: any(named: 'whereArgs'),
        ),
      ).thenThrow(Exception('db error'));

      when(() => db.transaction<void>(any())).thenAnswer((inv) async {
        final callback =
            inv.positionalArguments[0] as Future<void> Function(Transaction);
        return callback(txn);
      });

      expect(
        () => dataSource.deleteTaskCompletely(1),
        throwsA(isA<LocalDatabaseException>()),
      );
    },
  );

  ////////////////// deleteDayTaskConnection //////////////////
  test(
    'deleteDayTaskConnection deletes task day tasks table successfully',
    () async {
      when(
        () => db.delete(
          any(),
          where: any(named: 'where'),
          whereArgs: any(named: 'whereArgs'),
        ),
      ).thenAnswer((_) async => 1);

      await dataSource.deleteDayTaskConnection(sampleDay, 54);

      verify(
        () => db.delete(
          DayTasksTableKeys.dayTasksTableKey,
          where:
              '${DayTasksTableKeys.dayTaskDayKey} = ? AND ${DayTasksTableKeys.dayTaskTaskKey} = ?',
          whereArgs: [sampleDay, 54],
        ),
      ).called(1);
    },
  );

  test(
    'deleteDayTaskConnection throws LocalDatabaseException when db.delete throws',
    () async {
      when(
        () => db.delete(
          any(),
          where: any(named: 'where'),
          whereArgs: any(named: 'whereArgs'),
        ),
      ).thenThrow(Exception('db error'));

      expect(
        () => dataSource.deleteDayTaskConnection(sampleDay, 54),
        throwsA(isA<LocalDatabaseException>()),
      );
    },
  );

  ////////////////// deleteDayTaskConnectionAndSetTaskNotRecurring //////////////////
  test(
    'deleteDayTaskConnectionAndSetTaskNotRecurring deletes task and sets unrecurring successfully',
    () async {
      when(() => db.transaction<void>(any())).thenAnswer((inv) {
        final callback =
            inv.positionalArguments[0] as Future<void> Function(Transaction);

        return callback(txn);
      });

      when(
        () => txn.delete(
          DayTasksTableKeys.dayTasksTableKey,
          where:
              '${DayTasksTableKeys.dayTaskDayKey} = ? AND ${DayTasksTableKeys.dayTaskTaskKey} = ?',
          whereArgs: [sampleDay, 54],
        ),
      ).thenAnswer((_) async => 1);

      when(
        () => txn.update(
          TasksTableKeys.tasksTableKey,
          {TasksTableKeys.taskIsRecurringKey: 0},
          where: '${DayTasksTableKeys.dayTaskTaskKey} = ?',
          whereArgs: [54],
        ),
      ).thenAnswer((_) async => 1);

      await dataSource.deleteDayTaskConnectionAndSetTaskNotRecurring(
        sampleDay,
        54,
      );

      verify(
        () => txn.delete(
          DayTasksTableKeys.dayTasksTableKey,
          where:
              '${DayTasksTableKeys.dayTaskDayKey} = ? AND ${DayTasksTableKeys.dayTaskTaskKey} = ?',
          whereArgs: [sampleDay, 54],
        ),
      ).called(1);

      verify(
        () => txn.update(
          TasksTableKeys.tasksTableKey,
          {TasksTableKeys.taskIsRecurringKey: 0},
          where: '${TasksTableKeys.taskIdKey} = ?',
          whereArgs: [54],
        ),
      ).called(1);
    },
  );

  test(
    'deleteDayTaskConnectionAndSetTaskNotRecurring throws LocalDatabaseException when db.delete throws',
    () async {
      when(
        () => txn.delete(
          any(),
          where: any(named: 'where'),
          whereArgs: any(named: 'whereArgs'),
        ),
      ).thenThrow(Exception('db error'));

      when(() => db.transaction<void>(any())).thenAnswer((inv) async {
        final callback =
            inv.positionalArguments[0] as Future<dynamic> Function(Transaction);
        return callback(txn);
      });

      expect(
        () => dataSource.deleteDayTaskConnectionAndSetTaskNotRecurring(
          sampleDay,
          54,
        ),
        throwsA(isA<LocalDatabaseException>()),
      );
    },
  );
}
