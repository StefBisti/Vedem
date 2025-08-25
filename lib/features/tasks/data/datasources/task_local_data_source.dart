import 'package:flutter/foundation.dart';
import 'package:vedem/core/database/database_keys.dart';
import 'package:vedem/core/error/error_messages.dart';
import 'package:vedem/core/error/exceptions.dart';
import 'package:vedem/features/tasks/data/datasources/task_data_source.dart';
import 'package:vedem/features/tasks/data/models/task_model.dart';
import 'package:sqflite/sqflite.dart';

// TO DO See trashed tasks
class TaskLocalDataSource implements TaskDataSource {
  final Database db;

  const TaskLocalDataSource({required this.db});

  @override
  Future<TaskModel> addNewTaskAndAssignToDay(
    String dayId,
    int categoryId,
    String content,
    bool isRecurring,
    int diamonds,
  ) async {
    try {
      return await db.transaction((txn) async {
        final taskId = await txn.insert(TasksKeys.table, {
          TasksKeys.categoryId: categoryId,
          TasksKeys.content: content,
          TasksKeys.isRecurring: isRecurring ? 1 : 0,
          TasksKeys.diamonds: diamonds,
        });

        await txn.insert(DayTasksKeys.table, {
          DayTasksKeys.day: dayId,
          DayTasksKeys.task: taskId,
          DayTasksKeys.done: 0,
        });

        return TaskModel(
          taskId: taskId,
          categoryId: categoryId,
          content: content,
          isRecurring: isRecurring,
          diamonds: diamonds,
          isDone: false,
        );
      });
    } catch (e) {
      debugPrint(e.toString());
      throw LocalDatabaseException(message: createTaskError);
    }
  }

  @override
  Future<void> addNewDayTaskConnection(
    String dayId,
    int taskId,
    bool done,
  ) async {
    try {
      await db.insert(DayTasksKeys.table, {
        DayTasksKeys.day: dayId,
        DayTasksKeys.task: taskId,
        DayTasksKeys.done: done ? 1 : 0,
      });
    } catch (e) {
      debugPrint(e.toString());
      throw LocalDatabaseException(message: createTaskError);
    }
  }

  @override
  Future<List<TaskModel>> readTasksForDay(String dayId) async {
    try {
      final result = await db.rawQuery(
        '''
          SELECT 
            t.${TasksKeys.id},
            t.${TasksKeys.categoryId},
            t.${TasksKeys.content},
            t.${TasksKeys.isRecurring},
            t.${TasksKeys.diamonds},
            dt.${DayTasksKeys.done}
          FROM ${DayTasksKeys.table} dt
          INNER JOIN ${TasksKeys.table} t ON dt.${DayTasksKeys.task} = t.${TasksKeys.id}
          WHERE dt.${DayTasksKeys.day} = ?
        ''',
        [dayId],
      );
      return result.map((e) => TaskModel.fromMap(e)).toList();
    } catch (e) {
      debugPrint(e.toString());
      throw LocalDatabaseException(message: readTasksError);
    }
  }

  @override
  Future<List<TaskModel>> readTasksForMonth(String monthId) async {
    try {
      final parts = monthId.split('-');

      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);

      final nextMonth = (month == 12)
          ? DateTime(year + 1, 1, 1)
          : DateTime(year, month + 1, 1);

      String formatDate(DateTime d) =>
          '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

      final startStr = '$monthId-01';
      final endStr = formatDate(nextMonth);

      final result = await db.rawQuery(
        '''
          SELECT DISTINCT
            t.${TasksKeys.id},
            t.${TasksKeys.categoryId},
            t.${TasksKeys.content},
            t.${TasksKeys.isRecurring},
            t.${TasksKeys.diamonds}
          FROM ${DayTasksKeys.table} dt
          INNER JOIN ${TasksKeys.table} t ON dt.${DayTasksKeys.task} = t.${TasksKeys.id}
          WHERE dt.${DayTasksKeys.day} >= ? AND dt.${DayTasksKeys.day} < ?
        ''',
        [startStr, endStr],
      );
      return result.map((e) => TaskModel.fromMap(e)).toList();
    } catch (e) {
      debugPrint(e.toString());
      throw LocalDatabaseException(message: readTasksError);
    }
  }

  @override
  Future<List<TaskModel>> getDefaultTasksNotAssignedToDay(String dayId) async {
    // to do: use dayId in future update to get second chance tasks
    try {
      final result = await db.rawQuery('''
      SELECT
        ${TasksKeys.id},
        ${TasksKeys.categoryId},
        ${TasksKeys.content},
        ${TasksKeys.isRecurring},
        ${TasksKeys.diamonds}
      FROM ${TasksKeys.table}
      WHERE ${TasksKeys.isRecurring} = 1
    ''');
      return result.map((e) => TaskModel.fromMap(e)).toList();
    } catch (e) {
      debugPrint(e.toString());
      throw LocalDatabaseException(message: readTasksError);
    }
  }

  @override
  Future<void> updateGenericTask(
    int taskId,
    int categoryId,
    String content,
    bool isRecurring,
    int diamonds,
  ) async {
    try {
      await db.update(
        TasksKeys.table,
        {
          TasksKeys.categoryId: categoryId,
          TasksKeys.content: content,
          TasksKeys.isRecurring: isRecurring ? 1 : 0,
          TasksKeys.diamonds: diamonds,
        },
        where: '${TasksKeys.id} = ?',
        whereArgs: [taskId],
      );
    } catch (e) {
      debugPrint(e.toString());
      throw LocalDatabaseException(message: updateTaskError);
    }
  }

  @override
  Future<void> updateDayTaskConnection(
    String dayId,
    int taskId,
    bool done,
  ) async {
    try {
      await db.update(
        DayTasksKeys.table,
        {DayTasksKeys.done: done ? 1 : 0},
        where:
            '${DayTasksKeys.day} = ? AND ${DayTasksKeys.task} = ?',
        whereArgs: [dayId, taskId],
      );
    } catch (e) {
      debugPrint(e.toString());
      throw LocalDatabaseException(message: updateTaskError);
    }
  }

  @override
  Future<void> deleteTaskCompletely(int taskId) async {
    try {
      await db.transaction<void>((txn) async {
        await txn.delete(
          TasksKeys.table,
          where: '${TasksKeys.id} = ?',
          whereArgs: [taskId],
        );
        await txn.delete(
          DayTasksKeys.table,
          where: '${DayTasksKeys.task} = ?',
          whereArgs: [taskId],
        );
      });
    } catch (e) {
      debugPrint(e.toString());
      throw LocalDatabaseException(message: deleteTaskError);
    }
  }

  @override
  Future<void> deleteDayTaskConnection(String dayId, int taskId) async {
    try {
      await db.delete(
        DayTasksKeys.table,
        where:
            '${DayTasksKeys.day} = ? AND ${DayTasksKeys.task} = ?',
        whereArgs: [dayId, taskId],
      );
    } catch (e) {
      debugPrint(e.toString());
      throw LocalDatabaseException(message: deleteTaskError);
    }
  }

  @override
  Future<void> deleteDayTaskConnectionAndSetTaskNotRecurring(
    String dayId,
    int taskId,
  ) async {
    try {
      await db.transaction<void>((txn) async {
        await txn.delete(
          DayTasksKeys.table,
          where:
              '${DayTasksKeys.day} = ? AND ${DayTasksKeys.task} = ?',
          whereArgs: [dayId, taskId],
        );
        await txn.update(
          TasksKeys.table,
          {TasksKeys.isRecurring: 0},
          where: '${TasksKeys.id} = ?',
          whereArgs: [taskId],
        );
      });
    } catch (e) {
      debugPrint(e.toString());
      throw LocalDatabaseException(message: deleteTaskError);
    }
  }
}
