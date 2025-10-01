import 'package:sqflite/sqflite.dart';
import 'package:vedem/core/database/database_keys.dart';

class AppDatabase {
  static Future<Database> open(String path) async {
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''

          CREATE TABLE $tasksTableKey (
            $taskIdKey INTEGER PRIMARY KEY AUTOINCREMENT,
            $taskCategoryIdKey INTEGER NOT NULL,
            $taskContentKey TEXT NOT NULL,
            $taskIsStarredKey INTEGER NOT NULL DEFAULT 0,
            $taskIsDailyKey INTEGER NOT NULL DEFAULT 0
          );

          CREATE TABLE $dayTasksTableKey (
            $dayTaskIdKey INTEGER PRIMARY KEY AUTOINCREMENT,
            $dayTaskDayIdKey TEXT NOT NULL,
            $dayTaskTaskIdKey INTEGER NOT NULL,
            $dayTaskDoneTypeKey INTEGER NOT NULL DEFAULT 0,
            $dayTaskIsSecondChanceKey INTEGER NOT NULL DEFAULT 0,
            $dayTaskEncodedSubtasksKey TEXT,
            $dayTaskImportanceKey INTEGER,
            $dayTaskEffortRequiredKey INTEGER,
            $dayTaskTimeRequiredKey INTEGER,
            $dayTaskNotGreatDiamondsKey INTEGER,
            $dayTaskOnPointDiamondsKey INTEGER,
            $dayTaskAwesomeDiamondsKey INTEGER,
            $dayTaskDueTimeInMinutesKey INTEGER,
            $dayTaskNotifyTimeInMinutesKey INTEGER,
            FOREIGN KEY($dayTaskTaskIdKey) REFERENCES $tasksTableKey($taskIdKey) ON DELETE CASCADE
          );
          CREATE INDEX idx_day_tasks_day_id ON $dayTasksTableKey($dayTaskDayIdKey);
          CREATE INDEX idx_day_tasks_task_id ON $dayTasksTableKey($dayTaskTaskIdKey);
          CREATE INDEX idx_tasks_task_id ON $tasksTableKey($taskCategoryIdKey);
        ''');
      },
    );
  }
}
