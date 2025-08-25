import 'package:sqflite/sqflite.dart';
import 'package:vedem/core/database/database_keys.dart';

class AppDatabase {
  static Future<Database> open(String path) async {
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
            CREATE TABLE ${TasksKeys.table} (
              ${TasksKeys.id} INTEGER PRIMARY KEY AUTOINCREMENT,
              ${TasksKeys.categoryId} INTEGER NOT NULL,
              ${TasksKeys.content} TEXT NOT NULL,
              ${TasksKeys.isRecurring} INTEGER NOT NULL,
              ${TasksKeys.diamonds} INTEGER NOT NULL
            )
          ''');
        await db.execute('''
            CREATE TABLE ${DayTasksKeys.table} (
              ${DayTasksKeys.id} INTEGER PRIMARY KEY AUTOINCREMENT,
              ${DayTasksKeys.day} TEXT NOT NULL,
              ${DayTasksKeys.task} INTEGER NOT NULL,
              ${DayTasksKeys.done} INTEGER NOT NULL DEFAULT 0,
              FOREIGN KEY (${DayTasksKeys.task}) REFERENCES ${TasksKeys.table} (${TasksKeys.id})
            );
          ''');
        await db.execute(
          'CREATE INDEX idx_tasks_category_id ON ${TasksKeys.table}(${TasksKeys.categoryId});',
        );
        await db.execute(
          'CREATE INDEX idx_day_tasks_task_id ON ${DayTasksKeys.table}(${DayTasksKeys.task});',
        );
        await db.execute(
          'CREATE INDEX idx_day_tasks_day_id ON ${DayTasksKeys.table}(${DayTasksKeys.day});',
        );
      },
    );
  }
}
