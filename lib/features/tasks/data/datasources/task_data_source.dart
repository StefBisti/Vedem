import 'package:vedem/features/tasks/data/models/day_task_entry_model.dart';
import 'package:vedem/features/tasks/data/models/task_entry_model.dart';
import 'package:vedem/features/tasks/data/models/user_task_model.dart';

abstract interface class TaskDataSource {
  Future<List<UserTaskModel>> readUserTasksByDay(String dayId);
  Future<List<UserTaskModel>> readDailyOrNotDoneUserTasksFromDay(String dayId);
  Future<List<TaskEntryModel>> readAllTaskEntries();
  Future<List<TaskEntryModel>> readStarredTaskEntries();
  Future<List<TaskEntryModel>> readTrashedTaskEntries();
  Future<List<TaskEntryModel>> readTaskEntriesByCategoryId(int categoryId);
  Future<TaskEntryModel?> readTaskEntryWithContent(String content);

  Future<UserTaskModel> writeTaskWithDayTask(
    TaskEntryModel taskEntry,
    DayTaskEntryModel dayTaskEntry,
  );
  Future<void> writeDayTaskEntry(DayTaskEntryModel dayTaskEntry);
  Future<void> writeDayTaskEntries(List<DayTaskEntryModel> dayTaskEntries);

  Future<void> updateTaskEntry(TaskEntryModel taskEntry);
  Future<void> updateDayTaskEntry(DayTaskEntryModel dayTaskEntry);
  Future<void> updateTaskAndDayTaskEntry(
    TaskEntryModel taskEntry,
    DayTaskEntryModel dayTaskEntry,
  );
  Future<void> setDayTaskDoneType(int dayTaskId, int doneType);
  Future<void> setDayTaskNewSubtaskEcoding(
    int dayTaskId,
    String newSubtaskEncoding,
  );

  Future<void> deleteTaskEntryRecursively(int taskId);
  Future<void> deleteDayTaskEntry(int dayTaskId);
}
