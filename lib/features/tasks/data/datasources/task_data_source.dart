import 'package:vedem/features/tasks/data/models/task_model.dart';

abstract interface class TaskDataSource {
  Future<TaskModel> addNewGenericTask(
    int categoryId,
    String content,
    bool isRecurring,
    int diamonds,
  );

  Future<void> addNewDayTaskConnection(String dayId, int taskId, int done);

  Future<List<TaskModel>> readTasksForDay(String dayId);

  Future<List<TaskModel>> getDefaultTasks(String dayId);

  Future<void> updateGenericTask(TaskModel newTask);

  Future<void> updateDayTaskConnection(String dayId, int taskId, int done);

  Future<void> deleteGenericTask(int taskId);

  Future<void> deleteDayTaskConnection(String dayId, int taskId);
}
