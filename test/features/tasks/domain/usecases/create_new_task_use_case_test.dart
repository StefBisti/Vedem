import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vedem/features/tasks/domain/entities/task_entity.dart';
import 'package:vedem/features/tasks/domain/repositories/task_repository.dart';
import 'package:vedem/features/tasks/domain/usecases/create_new_task_use_case.dart';

class MockTaskRepository extends Mock implements TaskRepository {}

void main() {
  late CreateNewTaskUseCase useCase;
  late MockTaskRepository taskRepository;

  final TaskEntity sampleTask = TaskEntity(
    taskId: 54,
    categoryId: 1,
    content: 'test',
    isRecurring: true,
    diamonds: 34,
    isDone: false,
  );

  setUp(() {
    taskRepository = MockTaskRepository();
    useCase = CreateNewTaskUseCase(taskRepository: taskRepository);
  });

  test('Should get right result from repository', () async {
    when(
      () => taskRepository.createNewTaskAndAssignToDay(
        any(),
        any(),
        any(),
        any(),
        any(),
      ),
    ).thenAnswer((_) async => right(sampleTask));
    final res = await useCase.call(
      CreateNewTaskUseCaseParams(
        dayId: '2025-08-18',
        categoryId: 1,
        content: 'test',
        isRecurring: true,
        diamonds: 34,
      ),
    );
    expect(res, right(sampleTask));
  });

  test('Equatable CreateNewTaskUseCaseParams', () async {
    CreateNewTaskUseCaseParams p1 = CreateNewTaskUseCaseParams(
      dayId: '2025-08-18',
      categoryId: 1,
      content: 'test',
      isRecurring: false,
      diamonds: 43,
    );
    CreateNewTaskUseCaseParams p2 = CreateNewTaskUseCaseParams(
      dayId: '2025-08-18',
      categoryId: 1,
      content: 'test',
      isRecurring: false,
      diamonds: 43,
    );
    expect(p1, p2);
  });
}
