import 'package:flutter_test/flutter_test.dart';
import 'package:vedem/core/database/database_keys.dart';
import 'package:vedem/features/tasks/data/models/task_model.dart';

void main(){
  final TaskModel before = TaskModel(taskId: 1, categoryId: 1, content: 'before', isRecurring: true, diamonds: 232, isDone: false);
  final TaskModel after0 = TaskModel(taskId: 1, categoryId: 1, content: 'before', isRecurring: false, diamonds: 232, isDone: false);
  final TaskModel after1 = TaskModel(taskId: 1, categoryId: 1, content: 'after', isRecurring: true, diamonds: 232, isDone: false);

  test('task model copy with', () {
    expect(before.copyWith(isRecurring: false), after0);
    expect(before.copyWith(content: 'after'), after1);
  });

  final sampleDbRow1 = {
    TasksTableKeys.taskIdKey: 54,
    TasksTableKeys.taskCategoryIdKey: 1,
    TasksTableKeys.taskContentKey: 'test',
    TasksTableKeys.taskIsRecurringKey: 1,
    TasksTableKeys.taskDiamondsKey: 34,
    DayTasksTableKeys.dayTaskDoneKey: 0,
  };
  final sampleDbRow2 = {
    TasksTableKeys.taskIdKey: 54,
    TasksTableKeys.taskCategoryIdKey: 1,
    TasksTableKeys.taskContentKey: 'test',
    TasksTableKeys.taskIsRecurringKey: 1,
    TasksTableKeys.taskDiamondsKey: 34,
  };
  final TaskModel sampleTask = TaskModel(
    taskId: 54,
    categoryId: 1,
    content: 'test',
    isRecurring: true,
    diamonds: 34,
    isDone: false,
  );

  test('task model from map', () {
    expect(TaskModel.fromMap(sampleDbRow1), sampleTask);
    expect(TaskModel.fromMap(sampleDbRow2), sampleTask);
  });
}