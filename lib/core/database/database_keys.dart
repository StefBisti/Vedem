class TasksTableKeys {
  TasksTableKeys._();
  static const String tasksTableKey = 'tasks';
  static const String taskIdKey = 'task_id';
  static const String taskCategoryIdKey = 'category_id';
  static const String taskContentKey = 'content';
  static const String taskIsRecurringKey = 'is_recurring';
  static const String taskDiamondsKey = 'diamonds';
}

class DayTasksTableKeys {
  DayTasksTableKeys._();
  static const String dayTasksTableKey = 'day_tasks';
  static const String dayTaskIdKey = 'day_task_id';
  static const String dayTaskDayKey = 'day_id';
  static const String dayTaskTaskKey = 'task_id';
  static const String dayTaskDoneKey = 'done';
}
