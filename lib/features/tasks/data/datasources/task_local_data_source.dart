import 'package:flutter/foundation.dart';
import 'package:vedem/core/database/database_keys.dart';
import 'package:vedem/core/error/error_messages.dart';
import 'package:vedem/core/error/exceptions.dart';
import 'package:vedem/features/tasks/data/datasources/task_data_source.dart';
import 'package:vedem/features/tasks/data/models/task_model.dart';
import 'package:sqflite/sqflite.dart';

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
        final taskId = await txn.insert(TasksTableKeys.tasksTableKey, {
          TasksTableKeys.taskCategoryIdKey: categoryId,
          TasksTableKeys.taskContentKey: content,
          TasksTableKeys.taskIsRecurringKey: isRecurring ? 1 : 0,
          TasksTableKeys.taskDiamondsKey: diamonds,
        });

        await txn.insert(DayTasksTableKeys.dayTasksTableKey, {
          DayTasksTableKeys.dayTaskDayKey: dayId,
          DayTasksTableKeys.dayTaskTaskKey: taskId,
          DayTasksTableKeys.dayTaskDoneKey: 0,
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
      await db.insert(DayTasksTableKeys.dayTasksTableKey, {
        DayTasksTableKeys.dayTaskDayKey: dayId,
        DayTasksTableKeys.dayTaskTaskKey: taskId,
        DayTasksTableKeys.dayTaskDoneKey: done ? 1 : 0,
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
        t.${TasksTableKeys.taskIdKey},
        t.${TasksTableKeys.taskCategoryIdKey},
        t.${TasksTableKeys.taskContentKey},
        t.${TasksTableKeys.taskIsRecurringKey},
        t.${TasksTableKeys.taskDiamondsKey},
        dt.${DayTasksTableKeys.dayTaskDoneKey}
      FROM ${DayTasksTableKeys.dayTasksTableKey} dt
      INNER JOIN ${TasksTableKeys.tasksTableKey} t ON dt.${DayTasksTableKeys.dayTaskTaskKey} = t.${TasksTableKeys.taskIdKey}
      WHERE dt.${DayTasksTableKeys.dayTaskDayKey} = ?
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
  Future<List<TaskModel>> getDefaultTasksNotAssignedToDay(String dayId) async {
    // to do: use dayId in future update to get second chance tasks
    try {
      final result = await db.rawQuery('''
      SELECT
        ${TasksTableKeys.taskIdKey},
        ${TasksTableKeys.taskCategoryIdKey},
        ${TasksTableKeys.taskContentKey},
        ${TasksTableKeys.taskIsRecurringKey},
        ${TasksTableKeys.taskDiamondsKey}
      FROM ${TasksTableKeys.tasksTableKey}
      WHERE ${TasksTableKeys.taskIsRecurringKey} = 1
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
        TasksTableKeys.tasksTableKey,
        {
          TasksTableKeys.taskCategoryIdKey: categoryId,
          TasksTableKeys.taskContentKey: content,
          TasksTableKeys.taskIsRecurringKey: isRecurring ? 1 : 0,
          TasksTableKeys.taskDiamondsKey: diamonds,
        },
        where: '${TasksTableKeys.taskIdKey} = ?',
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
        DayTasksTableKeys.dayTasksTableKey,
        {DayTasksTableKeys.dayTaskDoneKey: done ? 1 : 0},
        where:
            '${DayTasksTableKeys.dayTaskDayKey} = ? AND ${DayTasksTableKeys.dayTaskTaskKey} = ?',
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
          TasksTableKeys.tasksTableKey,
          where: '${TasksTableKeys.taskIdKey} = ?',
          whereArgs: [taskId],
        );
        await txn.delete(
          DayTasksTableKeys.dayTasksTableKey,
          where: '${DayTasksTableKeys.dayTaskTaskKey} = ?',
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
        DayTasksTableKeys.dayTasksTableKey,
        where:
            '${DayTasksTableKeys.dayTaskDayKey} = ? AND ${DayTasksTableKeys.dayTaskTaskKey} = ?',
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
          DayTasksTableKeys.dayTasksTableKey,
          where:
              '${DayTasksTableKeys.dayTaskDayKey} = ? AND ${DayTasksTableKeys.dayTaskTaskKey} = ?',
          whereArgs: [dayId, taskId],
        );
        await txn.update(
          TasksTableKeys.tasksTableKey,
          {TasksTableKeys.taskIsRecurringKey: 0},
          where:
              '${TasksTableKeys.taskIdKey} = ?',
          whereArgs: [taskId],
        );
      });
    } catch (e) {
      debugPrint(e.toString());
      throw LocalDatabaseException(message: deleteTaskError);
    }
  }
}
