import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vedem/core/error/error_messages.dart';
import 'package:vedem/core/error/failures.dart';
import 'package:vedem/features/tasks/domain/entities/task_entity.dart';
import 'package:vedem/features/tasks/domain/usecases/create_new_task_use_case.dart';
import 'package:vedem/features/tasks/domain/usecases/delete_task_usecase.dart';
import 'package:vedem/features/tasks/domain/usecases/initialize_tasks_for_day_use_case.dart';
import 'package:vedem/features/tasks/domain/usecases/read_tasks_for_day_usecase.dart';
import 'package:vedem/features/tasks/domain/usecases/set_task_usecase.dart';
import 'package:vedem/features/tasks/domain/usecases/update_task_usecase.dart';
import 'package:vedem/features/tasks/presentation/bloc/tasks_bloc.dart';

class MockCreateNewTaskUseCase extends Mock implements CreateNewTaskUseCase {}

class FakeCreateNewTaskUseCaseParams extends Fake
    implements CreateNewTaskUseCaseParams {}

class MockInitializeTasksForDayUseCase extends Mock
    implements InitializeTasksForDayUseCase {}

class MockReadTasksForDayUseCase extends Mock
    implements ReadTasksForDayUseCase {}

class MockUpdateTaskUseCase extends Mock implements UpdateTaskUseCase {}

class MockDeleteTaskUseCase extends Mock implements DeleteTaskUseCase {}

class MockSetTaskUseCase extends Mock implements SetTaskUseCase {}

void main() {
  late TasksBloc bloc;
  late MockCreateNewTaskUseCase createNewTaskUseCase;
  late MockInitializeTasksForDayUseCase initializeTasksForDayUseCase;
  late MockReadTasksForDayUseCase readTasksForDayUseCase;
  late MockUpdateTaskUseCase updateTaskUseCase;
  late MockDeleteTaskUseCase deleteTaskUseCase;
  late MockSetTaskUseCase setTaskUseCase;

  final TaskEntity sampleTask1 = TaskEntity(
    taskId: 1,
    categoryId: 1,
    content: 'test 1',
    isRecurring: true,
    diamonds: 34,
    isDone: false,
  );
  final TaskEntity sampleTask2 = TaskEntity(
    taskId: 2,
    categoryId: 3,
    content: 'test 2',
    isRecurring: false,
    diamonds: 342,
    isDone: false,
  );

  setUp(() {
    createNewTaskUseCase = MockCreateNewTaskUseCase();
    initializeTasksForDayUseCase = MockInitializeTasksForDayUseCase();
    readTasksForDayUseCase = MockReadTasksForDayUseCase();
    updateTaskUseCase = MockUpdateTaskUseCase();
    deleteTaskUseCase = MockDeleteTaskUseCase();
    setTaskUseCase = MockSetTaskUseCase();
    bloc = TasksBloc(
      createNewTaskUseCase: createNewTaskUseCase,
      initializeTasksForDayUseCase: initializeTasksForDayUseCase,
      readTasksForDayUseCase: readTasksForDayUseCase,
      updateTaskUseCase: updateTaskUseCase,
      deleteTaskUseCase: deleteTaskUseCase,
      setTaskUseCase: setTaskUseCase,
    );
  });

  setUpAll(() {
    registerFallbackValue(FakeCreateNewTaskUseCaseParams());
  });

  tearDown(() {
    bloc.close();
  });

  group('CreateNewTaskEvent', () {
    test(
      'when state is not TasksSuccessState emits TasksFailureState with invalid state message',
      () async {
        expect(bloc.state, isNot(isA<TasksSuccessState>()));
        bloc.add(
          CreateNewTaskEvent(
            dayId: '2025-08-18',
            categoryId: 1,
            content: 'test',
            isRecurring: true,
            diamonds: 32,
          ),
        );
        expect(
          bloc.stream,
          emitsInOrder([
            TasksFailureState('Tried to add task in an invalid app state'),
          ]),
        );
      },
    );
    blocTest<TasksBloc, TasksState>(
      'optimistic, then replace with server created task on success',
      build: () {
        bloc.emit(TasksSuccessState(tasks: [sampleTask1]));
        return bloc;
      },
      act: (bloc) {
        when(() => createNewTaskUseCase.call(any())).thenAnswer((_) async {
          Future.delayed(Duration(milliseconds: 2000));
          return right(sampleTask2);
        });
        bloc.add(
          CreateNewTaskEvent(
            dayId: '2025-08-18',
            categoryId: 3,
            content: 'test 2',
            isRecurring: false,
            diamonds: 342,
          ),
        );
      },
      expect: () => <Matcher>[
        isA<TasksSuccessState>()
            .having((s) => s.tasks.length, 'length', 2)
            .having(
              (s) => s.tasks.last.taskId,
              'temp id is negative',
              lessThan(0),
            ),
        isA<TasksSuccessState>()
            .having((s) => s.tasks.length, 'length', 2)
            .having(
              (s) => s.tasks.any((t) => t.taskId == 2),
              'task created',
              isTrue,
            )
            .having(
              (s) => s.tasks.any((t) => t.taskId < 0),
              'no temp left',
              isFalse,
            ),
      ],
    );

    blocTest(
      'optimistic, but remove the task when use case fails',
      build: () {
        bloc.emit(TasksSuccessState(tasks: [sampleTask1]));
        return bloc;
      },
      act: (bloc) {
        when(() => createNewTaskUseCase.call(any())).thenAnswer((_) async {
          Future.delayed(Duration(milliseconds: 2000));
          return left(LocalDatabaseFailure(addTaskError));
        });
        bloc.add(
          CreateNewTaskEvent(
            dayId: '2025-08-18',
            categoryId: 3,
            content: 'test 2',
            isRecurring: false,
            diamonds: 342,
          ),
        );
      },
      expect: () => <Matcher>[
        isA<TasksSuccessState>()
            .having((s) => s.tasks.length, 'length', 2)
            .having(
              (s) => s.tasks.last.taskId,
              'temp is negative',
              lessThan(0),
            ),
        isA<TasksSuccessState>().having((s) => s.tasks.length, 'length', 1),
        isA<TasksFailureState>().having(
          (s) => s.failure,
          'message',
          contains(addTaskError),
        ),
      ],
    );
  });
}
