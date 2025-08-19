import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:vedem/core/database/database_keys.dart';
import 'package:vedem/core/error/exceptions.dart';
import 'package:vedem/features/tasks/data/datasources/task_local_data_source.dart';
import 'package:vedem/features/tasks/data/models/task_model.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Database db;
  late TaskLocalDataSource dataSource;

  Future<void> createSchema({required bool includeDayTasks}) async {
    // create tasks table
    await db.execute('''
      CREATE TABLE ${TasksTableKeys.tasksTableKey} (
        ${TasksTableKeys.taskIdKey} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${TasksTableKeys.taskCategoryIdKey} INTEGER NOT NULL,
        ${TasksTableKeys.taskContentKey} TEXT NOT NULL,
        ${TasksTableKeys.taskIsRecurringKey} INTEGER NOT NULL DEFAULT 0,
        ${TasksTableKeys.taskDiamondsKey} INTEGER NOT NULL DEFAULT 0
      );
    ''');

    if (includeDayTasks) {
      await db.execute('''
        CREATE TABLE ${DayTasksTableKeys.dayTasksTableKey} (
          ${DayTasksTableKeys.dayTaskIdKey} INTEGER PRIMARY KEY AUTOINCREMENT,
          ${DayTasksTableKeys.dayTaskDayKey} TEXT NOT NULL,
          ${DayTasksTableKeys.dayTaskTaskKey} INTEGER NOT NULL,
          ${DayTasksTableKeys.dayTaskDoneKey} INTEGER NOT NULL DEFAULT 0
        );
      ''');
    }
  }

  setUp(() async {
    // open an in-memory database per test
    db = await databaseFactory.openDatabase(inMemoryDatabasePath);
    dataSource = TaskLocalDataSource(db: db);
  });

  tearDown(() async {
    await db.close();
  });

  test('addNewTaskAndAssignToDay succeeds and writes both tables', () async {
    await createSchema(includeDayTasks: true);

    final dayId = '2025-08-19';
    final categoryId = 42;
    final content = 'Test task';
    final isRecurring = true;
    final diamonds = 5;

    final TaskModel created = await dataSource.addNewTaskAndAssignToDay(
      dayId,
      categoryId,
      content,
      isRecurring,
      diamonds,
    );

    // returned model must have a positive taskId
    expect(created.taskId, isNotNull);
    expect(created.taskId, greaterThan(0));

    // tasks table should contain exactly one row with expected values
    final tasksRows = await db.query(TasksTableKeys.tasksTableKey);
    expect(tasksRows.length, 1);
    final taskRow = tasksRows.first;
    expect(taskRow[TasksTableKeys.taskCategoryIdKey], categoryId);
    expect(taskRow[TasksTableKeys.taskContentKey], content);

    // is_recurring must be stored as integer 1
    final isRecurringStored = taskRow[TasksTableKeys.taskIsRecurringKey];
    expect(isRecurringStored, anyOf(1, equals(1))); // stored as 1

    // day_tasks should contain one row linking the day and inserted task id
    final dayTasksRows = await db.query(DayTasksTableKeys.dayTasksTableKey);
    expect(dayTasksRows.length, 1);
    final dtRow = dayTasksRows.first;
    expect(dtRow[DayTasksTableKeys.dayTaskDayKey], dayId);
    expect(dtRow[DayTasksTableKeys.dayTaskTaskKey], created.taskId);
    expect(dtRow[DayTasksTableKeys.dayTaskDoneKey], 0); // default done = 0
  });

  test('transaction rolls back when second insert fails (no day_tasks table)', () async {
    // Create only the tasks table - missing day_tasks causes second insert to fail
    await createSchema(includeDayTasks: false);

    final dayId = '2025-08-19';
    final categoryId = 99;
    final content = 'Will rollback';
    final isRecurring = false;
    final diamonds = 1;

    // Expect LocalDatabaseException to be thrown by your method
    expect(
      () async => await dataSource.addNewTaskAndAssignToDay(
        dayId,
        categoryId,
        content,
        isRecurring,
        diamonds,
      ),
      throwsA(isA<LocalDatabaseException>()),
    );

    // Because transaction failed, there should be NO rows in tasks table (rolled back)
    final tasksRows = await db.query(TasksTableKeys.tasksTableKey);
    expect(tasksRows, isEmpty);
  });
}
