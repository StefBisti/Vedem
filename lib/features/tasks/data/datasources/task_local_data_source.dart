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
  Future<TaskModel> addNewGenericTask(
    int categoryId,
    String content,
    bool isRecurring,
    int diamonds,
  ) async {
    try {
      int taskId = await db.insert(tasksTableKey, {
        taskCategoryIdKey: categoryId,
        taskContentKey: content,
        taskIsRecurringKey: isRecurring ? 1 : 0,
        taskDiamondsKey: diamonds,
      });
      return TaskModel(
        taskId: taskId,
        categoryId: categoryId,
        content: content,
        isRecurring: isRecurring,
        diamonds: diamonds,
        isDone: false,
      );
    } catch (e) {
      throw LocalDatabaseException(message: addTaskError);
    }
  }

  @override
  Future<void> addNewDayTaskConnection(
    String dayId,
    int taskId,
    int done,
  ) async {
    try {
      await db.insert(dayTasksTableKey, {
        dayTaskDayKey: dayId,
        dayTaskTaskKey: taskId,
        dayTaskDoneKey: done,
      });
    } catch (e) {
      throw LocalDatabaseException(message: addTaskError);
    }
  }

  @override
  Future<List<TaskModel>> readTasksForDay(String dayId) async {
    try {
      final result = await db.rawQuery('''
      SELECT 
        t.$taskIdKey,
        t.$taskCategoryIdKey,
        t.$taskContentKey,
        t.$taskIsRecurringKey,
        t.$taskDiamondsKey,
        dt.$dayTaskDoneKey
      FROM $dayTasksTableKey dt
      INNER JOIN $tasksTableKey t ON dt.$dayTaskTaskKey = t.$taskIdKey
      WHERE dt.$dayTaskDayKey = ?
    ''', [dayId]);
      return result.map((e) => TaskModel.fromMap(e)).toList();
    } catch (e) {
      throw LocalDatabaseException(message: readTasksError);
    }
  }

  @override
  Future<List<TaskModel>> getDefaultTasks(String dayId) async {
    try {
      final result = await db.rawQuery('''
      SELECT
        $taskIdKey,
        $taskCategoryIdKey,
        $taskContentKey,
        $taskIsRecurringKey,
        $taskDiamondsKey
      FROM $tasksTableKey
      WHERE $taskIsRecurringKey = 1
    ''');
      return result.map((e) => TaskModel.fromMap(e)).toList();
    } catch (e) {
      throw LocalDatabaseException(message: readTasksError);
    }
  }

  @override
  Future<void> updateGenericTask(TaskModel newTask) async {
    try {
      await db.update(
        tasksTableKey,
        {
          taskCategoryIdKey: newTask.categoryId,
          taskContentKey: newTask.content,
          taskIsRecurringKey: newTask.isRecurring,
          taskDiamondsKey: newTask.diamonds,
        },
        where: '$taskIdKey = ?',
        whereArgs: [newTask.taskId],
      );
    } catch (e) {
      throw LocalDatabaseException(message: updateTaskError);
    }
  }

  @override
  Future<void> updateDayTaskConnection(
    String dayId,
    int taskId,
    int done,
  ) async {
    try {
      await db.update(
        dayTasksTableKey,
        {dayTaskDayKey: dayId, dayTaskTaskKey: taskId, dayTaskDoneKey: done},
        where: '$dayTaskDayKey = ? AND $dayTaskTaskKey = ?',
        whereArgs: [dayId, taskId],
      );
    } catch (e) {
      throw LocalDatabaseException(message: updateTaskError);
    }
  }

  @override
  Future<void> deleteGenericTask(int taskId) async {
    try {
      await db.delete(
        tasksTableKey,
        where: '$taskIdKey = ?',
        whereArgs: [taskId],
      );
    } catch (e) {
      throw LocalDatabaseException(message: deleteTaskError);
    }
  }

  @override
  Future<void> deleteDayTaskConnection(String dayId, int taskId) async {
    try {
      await db.delete(
        dayTasksTableKey,
        where: '$dayTaskDayKey = ? AND $dayTaskTaskKey = ?',
        whereArgs: [dayId, taskId],
      );
    } catch (e) {
      throw LocalDatabaseException(message: deleteTaskError);
    }
  }
}
