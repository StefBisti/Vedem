import 'package:flutter_test/flutter_test.dart';
import 'package:vedem/features/tasks/domain/entities/task_entity.dart';

void main(){
  TaskEntity t1 = TaskEntity(taskId: 1, categoryId: 1, content: 'test', isRecurring: true, diamonds: 32, isDone: false);
  TaskEntity t2 = TaskEntity(taskId: 1, categoryId: 1, content: 'test', isRecurring: true, diamonds: 32, isDone: false);

  test('task entity equatable works', () {
    expect(t1, t2);
  });
}