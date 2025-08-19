import 'package:flutter_test/flutter_test.dart';
import 'package:vedem/features/tasks/data/models/task_model.dart';

void main(){
  final TaskModel before = TaskModel(taskId: 1, categoryId: 1, content: 'before', isRecurring: true, diamonds: 232, isDone: false);
  final TaskModel after = TaskModel(taskId: 1, categoryId: 1, content: 'after', isRecurring: true, diamonds: 232, isDone: false);

  test('task model copy with', () {
    expect(before.copyWith(content: 'after'), after);
  });
}