import 'package:vedem/core/database/database_keys.dart';
import 'package:vedem/features/tasks/data/datasources/task_data_source.dart';
import 'package:vedem/features/tasks/data/models/day_task_entry_model.dart';
import 'package:vedem/features/tasks/data/models/task_entry_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:vedem/features/tasks/data/models/user_task_model.dart';

class TaskLocalDataSource implements TaskDataSource {
  final Database db;

  const TaskLocalDataSource({required this.db});

  @override
  Future<List<UserTaskModel>> readUserTasksByDay(String dayId) async {
    final result = await db.rawQuery(
      '''
        SELECT d.*, t.*
        FROM $dayTasksTableKey d
        JOIN $tasksTableKey t ON d.$dayTaskTaskIdKey = t.$taskIdKey
        WHERE d.$dayTaskDayIdKey = ?
      ''',
      [dayId],
    );

    return result.map((row) {
      final task = TaskEntryModel.fromMap(row);
      final dayTask = DayTaskEntryModel.fromMap(row);
      return UserTaskModel(taskEntryModel: task, dayTaskEntryModel: dayTask);
    }).toList();
  }

  @override
  Future<List<UserTaskModel>> readDailyOrNotDoneUserTasksFromDay(
    String dayId,
  ) async {
    final result = await db.rawQuery(
      '''
        SELECT d.*, t.*
        FROM $dayTasksTableKey d
        JOIN $tasksTableKey t ON d.$dayTaskTaskIdKey = t.$taskIdKey
        WHERE d.$dayTaskDayIdKey = ?
          AND (t.$taskIsDailyKey = 1 OR (d.$dayTaskDoneTypeKey = 0 AND d.$dayTaskIsSecondChanceKey = 0))
      ''',
      [dayId],
    );

    return result.map((row) {
      final task = TaskEntryModel.fromMap(row);
      final dayTask = DayTaskEntryModel.fromMap(row);
      return UserTaskModel(taskEntryModel: task, dayTaskEntryModel: dayTask);
    }).toList();
  }

  @override
  Future<List<TaskEntryModel>> readAllTaskEntries() async {
    final result = await db.query(tasksTableKey);
    return result.map((row) => TaskEntryModel.fromMap(row)).toList();
  }

  @override
  Future<List<TaskEntryModel>> readStarredTaskEntries() async {
    final result = await db.query(
      tasksTableKey,
      where: '$taskIsStarredKey = ?',
      whereArgs: [1],
    );
    return result.map((row) => TaskEntryModel.fromMap(row)).toList();
  }

  @override
  Future<List<TaskEntryModel>> readTrashedTaskEntries() async {
    final result = await db.rawQuery('''
    SELECT t.*
    FROM $tasksTableKey t
    LEFT JOIN $dayTasksTableKey d
      ON t.$taskIdKey = d.$dayTaskTaskIdKey
    WHERE d.$dayTaskIdKey IS NULL
  ''');

    return result.map((row) => TaskEntryModel.fromMap(row)).toList();
  }

  @override
  Future<List<TaskEntryModel>> readTaskEntriesByCategoryId(
    int categoryId,
  ) async {
    final result = await db.query(
      tasksTableKey,
      where: '$taskCategoryIdKey = ?',
      whereArgs: [categoryId],
    );
    return result.map((row) => TaskEntryModel.fromMap(row)).toList();
  }

  @override
  Future<TaskEntryModel?> readTaskEntryWithContent(String content) async {
    final result = await db.query(
      tasksTableKey,
      where: '$taskContentKey = ?',
      whereArgs: [content],
    );
    if (result.isEmpty) return null;
    return TaskEntryModel.fromMap(result[0]);
  }

  @override
  Future<UserTaskModel> writeTaskWithDayTask(
    TaskEntryModel taskEntry,
    DayTaskEntryModel dayTaskEntry,
  ) async {
    return await db.transaction((txn) async {
      final taskId = await txn.insert(
        tasksTableKey,
        taskEntry.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      final dayTaskId = await txn.insert(
        dayTasksTableKey,
        dayTaskEntry.copyWith(taskId: taskId).toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      return UserTaskModel(
        taskEntryModel: taskEntry.copyWith(taskId: taskId),
        dayTaskEntryModel: dayTaskEntry.copyWith(
          dayTaskId: dayTaskId,
          taskId: taskId,
        ),
      );
    });
  }

  @override
  Future<void> writeDayTaskEntry(DayTaskEntryModel dayTaskEntry) async {
    await db.insert(
      dayTasksTableKey,
      dayTaskEntry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> writeDayTaskEntries(
    List<DayTaskEntryModel> dayTaskEntries,
  ) async {
    final batch = db.batch();
    for (final entry in dayTaskEntries) {
      batch.insert(
        dayTasksTableKey,
        entry.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  @override
  Future<void> updateTaskEntry(TaskEntryModel taskEntry) async {
    await db.update(
      tasksTableKey,
      taskEntry.toMap(),
      where: '$taskIdKey = ?',
      whereArgs: [taskEntry.taskId],
    );
  }

  @override
  Future<void> updateDayTaskEntry(DayTaskEntryModel dayTaskEntry) async {
    await db.update(
      dayTasksTableKey,
      dayTaskEntry.toMap(),
      where: '$dayTaskIdKey = ?',
      whereArgs: [dayTaskEntry.dayTaskId],
    );
  }

  @override
  Future<void> updateTaskAndDayTaskEntry(
    TaskEntryModel taskEntry,
    DayTaskEntryModel dayTaskEntry,
  ) async {
    final batch = db.batch();
    batch.update(
      tasksTableKey,
      taskEntry.toMap(),
      where: '$taskIdKey = ?',
      whereArgs: [taskEntry.taskId],
    );
    batch.update(
      dayTasksTableKey,
      dayTaskEntry.toMap(),
      where: '$dayTaskIdKey = ?',
      whereArgs: [dayTaskEntry.dayTaskId],
    );
    await batch.commit(noResult: true);
  }

  @override
  Future<void> setDayTaskDoneType(int dayTaskId, int doneType) async {
    db.update(
      dayTasksTableKey,
      {dayTaskDoneTypeKey: doneType},
      where: '$dayTaskIdKey = ?',
      whereArgs: [dayTaskId],
    );
  }

  @override
  Future<void> setDayTaskNewSubtaskEcoding(
    int dayTaskId,
    String newSubtaskEncoding,
  ) async {
    db.update(
      dayTasksTableKey,
      {dayTaskEncodedSubtasksKey: newSubtaskEncoding},
      where: '$dayTaskIdKey = ?',
      whereArgs: [dayTaskId],
    );
  }

  @override
  Future<void> deleteTaskEntryRecursively(int taskId) async {
    await db.delete(
      tasksTableKey,
      where: '$taskIdKey = ?',
      whereArgs: [taskId],
    );
  }

  @override
  Future<void> deleteDayTaskEntry(int dayTaskId) async {
    await db.delete(
      dayTasksTableKey,
      where: '$dayTaskIdKey = ?',
      whereArgs: [dayTaskId],
    );
  }
}
