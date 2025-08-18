import 'package:vedem/features/tasks/data/datasources/task_data_source.dart';
import 'package:vedem/features/tasks/data/models/task_model.dart';
import 'package:sqflite/sqflite.dart';

class LocalTaskDataSource implements TaskDataSource {
  final Database db;
  @override
  Future<void> addNewDayTaskConnection(String dayId, int taskId, int done) {
    
  }

  @override
  Future<void> addNewGenericTask(int categoryId, String content, bool isRecurring, int diamonds) {
    // TODO: implement addNewGenericTask
    throw UnimplementedError();
  }

  @override
  Future<void> deleteDayTaskConnection(String dayId, int taskId) {
    // TODO: implement deleteDayTaskConnection
    throw UnimplementedError();
  }

  @override
  Future<void> deleteGenericTask(int taskId) {
    // TODO: implement deleteGenericTask
    throw UnimplementedError();
  }

  @override
  Future<List<TaskModel>> readTasksForDay(String dayId) {
    // TODO: implement readTasksForDay
    throw UnimplementedError();
  }

  @override
  Future<void> updateDayTaskConnection(String dayId, int taskId, int done) {
    // TODO: implement updateDayTaskConnection
    throw UnimplementedError();
  }

  @override
  Future<void> updateGenericTask(int taskId, int categoryId, String content, bool isRecurring, int diamonds) {
    // TODO: implement updateGenericTask
    throw UnimplementedError();
  }
}