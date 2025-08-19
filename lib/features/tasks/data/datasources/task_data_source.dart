import 'package:vedem/features/tasks/data/models/task_model.dart';

abstract interface class TaskDataSource {
  Future<TaskModel> addNewTaskAndAssignToDay(
    String dayId,
    int categoryId,
    String content,
    bool isRecurring,
    int diamonds,
  );

  Future<void> addNewDayTaskConnection(String dayId, int taskId, bool done);

  Future<List<TaskModel>> readTasksForDay(String dayId);

  Future<List<TaskModel>> getDefaultTasksNotAssignedToDay(String dayId);

  Future<void> updateGenericTask(TaskModel newTask);

  Future<void> updateDayTaskConnection(String dayId, int taskId, bool done);

  Future<void> deleteGenericTask(int taskId);

  Future<void> deleteDayTaskConnection(String dayId, int taskId);
}
