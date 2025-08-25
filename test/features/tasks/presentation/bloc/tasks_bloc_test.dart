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
import 'package:vedem/features/tasks/domain/usecases/read_tasks_for_month_use_case.dart';
import 'package:vedem/features/tasks/domain/usecases/set_task_usecase.dart';
import 'package:vedem/features/tasks/domain/usecases/update_task_usecase.dart';
import 'package:vedem/features/tasks/presentation/bloc/tasks_bloc.dart';

class MockCreateNewTaskUseCase extends Mock implements CreateNewTaskUseCase {}

class FakeCreateNewTaskUseCaseParams extends Fake
    implements CreateNewTaskUseCaseParams {}

class MockInitializeTasksForDayUseCase extends Mock
    implements InitializeTasksForDayUseCase {}

class FakeInitializeTasksForDayUseCaseParams extends Fake
    implements InitializeTasksForDayUseCaseParams {}

class MockReadTasksForDayUseCase extends Mock
    implements ReadTasksForDayUseCase {}

class FakeReadTasksForDayUseCaseParams extends Fake
    implements ReadTasksForDayUseCaseParams {}

class MockReadTasksForMonthUseCase extends Mock
    implements ReadTasksForMonthUseCase {}

class FakeReadTasksForMonthUseCaseParams extends Fake
    implements ReadTasksForMonthUseCaseParams {}

class MockUpdateTaskUseCase extends Mock implements UpdateTaskUseCase {}

class FakeUpdateTaskUseCaseParams extends Fake
    implements UpdateTaskUseCaseParams {}

class MockDeleteTaskUseCase extends Mock implements DeleteTaskUseCase {}

class FakeDeleteTaskUseCase extends Fake implements DeleteTaskUseCaseParams {}

class MockSetTaskUseCase extends Mock implements SetTaskUseCase {}

class FakeSetTaskUseCaseParams extends Fake implements SetTaskUseCaseParams {}

void main() {
  late TasksBloc bloc;
  late MockCreateNewTaskUseCase createNewTaskUseCase;
  late MockInitializeTasksForDayUseCase initializeTasksForDayUseCase;
  late MockReadTasksForDayUseCase readTasksForDayUseCase;
  late MockReadTasksForMonthUseCase readTasksForMonthUseCase;
  late MockUpdateTaskUseCase updateTaskUseCase;
  late MockDeleteTaskUseCase deleteTaskUseCase;
  late MockSetTaskUseCase setTaskUseCase;

  final TaskEntity sampleTask1 = TaskEntity(
    taskId: 1,
    categoryId: 1,
    content: 'test 1',
    isRecurring: true,
    diamonds: 11,
    isDone: false,
  );
  final TaskEntity sampleTask2 = TaskEntity(
    taskId: 2,
    categoryId: 2,
    content: 'test 2',
    isRecurring: false,
    diamonds: 22,
    isDone: false,
  );
  final String sampleDayId = '2025-08-18';

  setUp(() {
    createNewTaskUseCase = MockCreateNewTaskUseCase();
    initializeTasksForDayUseCase = MockInitializeTasksForDayUseCase();
    readTasksForDayUseCase = MockReadTasksForDayUseCase();
    readTasksForMonthUseCase = MockReadTasksForMonthUseCase();
    updateTaskUseCase = MockUpdateTaskUseCase();
    deleteTaskUseCase = MockDeleteTaskUseCase();
    setTaskUseCase = MockSetTaskUseCase();
    bloc = TasksBloc(
      createNewTaskUseCase: createNewTaskUseCase,
      initializeTasksForDayUseCase: initializeTasksForDayUseCase,
      readTasksForDayUseCase: readTasksForDayUseCase,
      readTasksForMonthUseCase: readTasksForMonthUseCase,
      updateTaskUseCase: updateTaskUseCase,
      deleteTaskUseCase: deleteTaskUseCase,
      setTaskUseCase: setTaskUseCase,
    );
  });

  setUpAll(() {
    registerFallbackValue(FakeCreateNewTaskUseCaseParams());
    registerFallbackValue(FakeInitializeTasksForDayUseCaseParams());
    registerFallbackValue(FakeReadTasksForDayUseCaseParams());
    registerFallbackValue(FakeReadTasksForMonthUseCaseParams());
    registerFallbackValue(FakeUpdateTaskUseCaseParams());
    registerFallbackValue(FakeDeleteTaskUseCase());
    registerFallbackValue(FakeSetTaskUseCaseParams());
  });

  tearDown(() {
    bloc.close();
  });

  group('Creating a new task', () {
    blocTest<TasksBloc, TasksState>(
      'Trying to add a task while isLoading gives error',
      build: () {
        return bloc;
      },
      seed: () => TasksState(tasks: [], isLoading: true, error: null),
      act: (bloc) => bloc.add(
        CreateNewTaskEvent(
          dayId: sampleDayId,
          categoryId: sampleTask1.categoryId,
          content: sampleTask1.content,
          isRecurring: sampleTask1.isRecurring,
          diamonds: sampleTask1.diamonds,
        ),
      ),
      expect: () => [
        TasksState(
          tasks: [],
          isLoading: true,
          error: noOperationWhileIsLoadingError,
        ),
      ],
      verify: (bloc) {
        verifyZeroInteractions(createNewTaskUseCase);
      },
    );
    blocTest<TasksBloc, TasksState>(
      'Optimistically adds the task with negative id and replaces id when successful',
      build: () {
        when(
          () => createNewTaskUseCase.call(any()),
        ).thenAnswer((_) async => right(sampleTask1));
        return bloc;
      },
      seed: () => TasksState(tasks: [], isLoading: false, error: null),
      act: (bloc) => bloc.add(
        CreateNewTaskEvent(
          dayId: sampleDayId,
          categoryId: sampleTask1.categoryId,
          content: sampleTask1.content,
          isRecurring: sampleTask1.isRecurring,
          diamonds: sampleTask1.diamonds,
        ),
      ),
      expect: () => [
        predicate<TasksState>(
          (s) =>
              s.isLoading == true &&
              s.error == null &&
              s.tasks.length == 1 &&
              s.tasks[0].taskId < 0 &&
              s.tasks[0].content == sampleTask1.content,
        ),
        TasksState(tasks: [sampleTask1], isLoading: false, error: null),
      ],
      verify: (bloc) {
        verify(() => createNewTaskUseCase.call(any())).called(1);
      },
    );
    blocTest<TasksBloc, TasksState>(
      'Optimistically adds the task with negative id, deletes it when failure and emits error',
      build: () {
        when(
          () => createNewTaskUseCase.call(any()),
        ).thenAnswer((_) async => left(LocalDatabaseFailure(createTaskError)));
        return bloc;
      },
      seed: () => TasksState(tasks: [], isLoading: false, error: null),
      act: (bloc) => bloc.add(
        CreateNewTaskEvent(
          dayId: sampleDayId,
          categoryId: sampleTask1.categoryId,
          content: sampleTask1.content,
          isRecurring: sampleTask1.isRecurring,
          diamonds: sampleTask1.diamonds,
        ),
      ),
      expect: () => [
        predicate<TasksState>(
          (s) =>
              s.isLoading == true &&
              s.error == null &&
              s.tasks.length == 1 &&
              s.tasks[0].taskId < 0 &&
              s.tasks[0].content == sampleTask1.content,
        ),
        TasksState(tasks: [], isLoading: false, error: createTaskError),
      ],
      verify: (bloc) {
        verify(() => createNewTaskUseCase.call(any())).called(1);
      },
    );
  });

  group('Initialize tasks for a new day', () {
    blocTest<TasksBloc, TasksState>(
      'Trying to initialize tasks for a new day while isLoading gives error',
      build: () {
        return bloc;
      },
      seed: () => TasksState(tasks: [], isLoading: true, error: null),
      act: (bloc) => bloc.add(InitializeTasksForDayEvent(dayId: sampleDayId)),
      expect: () => [
        TasksState(
          tasks: [],
          isLoading: true,
          error: noOperationWhileIsLoadingError,
        ),
      ],
      verify: (bloc) {
        verifyZeroInteractions(initializeTasksForDayUseCase);
      },
    );
    blocTest<TasksBloc, TasksState>(
      'State will be initially loading, with no tasks, then will have the initialized day tasks if successful',
      build: () {
        when(
          () => initializeTasksForDayUseCase.call(any()),
        ).thenAnswer((_) async => right([sampleTask1, sampleTask2]));
        return bloc;
      },
      seed: () => TasksState(tasks: [], isLoading: false, error: null),
      act: (bloc) => bloc.add(InitializeTasksForDayEvent(dayId: sampleDayId)),
      expect: () => [
        TasksState(tasks: [], isLoading: true, error: null),
        TasksState(
          tasks: [sampleTask1, sampleTask2],
          isLoading: false,
          error: null,
        ),
      ],
      verify: (bloc) {
        verify(
          () => initializeTasksForDayUseCase.call(
            InitializeTasksForDayUseCaseParams(dayId: sampleDayId),
          ),
        );
      },
    );
    blocTest<TasksBloc, TasksState>(
      'State will be initially loading, with no tasks, then, if failure, will give the correct error message',
      build: () {
        when(
          () => initializeTasksForDayUseCase.call(any()),
        ).thenAnswer((_) async => left(LocalDatabaseFailure(readTasksError)));
        return bloc;
      },
      seed: () => TasksState(tasks: [], isLoading: false, error: null),
      act: (bloc) => bloc.add(InitializeTasksForDayEvent(dayId: sampleDayId)),
      expect: () => [
        TasksState(tasks: [], isLoading: true, error: null),
        TasksState(tasks: [], isLoading: false, error: readTasksError),
      ],
      verify: (bloc) {
        verify(
          () => initializeTasksForDayUseCase.call(
            InitializeTasksForDayUseCaseParams(dayId: sampleDayId),
          ),
        );
      },
    );
  });

  group('Read tasks for a day', () {
    blocTest<TasksBloc, TasksState>(
      'Trying to read tasks for a day a while isLoading gives error',
      build: () {
        return bloc;
      },
      seed: () => TasksState(tasks: [], isLoading: true, error: null),
      act: (bloc) => bloc.add(ReadTasksForDayEvent(dayId: sampleDayId)),
      expect: () => [
        TasksState(
          tasks: [],
          isLoading: true,
          error: noOperationWhileIsLoadingError,
        ),
      ],
      verify: (bloc) {
        verifyZeroInteractions(readTasksForDayUseCase);
      },
    );
    blocTest<TasksBloc, TasksState>(
      'State will be initially loading, with no tasks, then will have the day tasks if successful',
      build: () {
        when(
          () => readTasksForDayUseCase.call(any()),
        ).thenAnswer((_) async => right([sampleTask1, sampleTask2]));
        return bloc;
      },
      seed: () => TasksState(tasks: [], isLoading: false, error: null),
      act: (bloc) => bloc.add(ReadTasksForDayEvent(dayId: sampleDayId)),
      expect: () => [
        TasksState(tasks: [], isLoading: true, error: null),
        TasksState(
          tasks: [sampleTask1, sampleTask2],
          isLoading: false,
          error: null,
        ),
      ],
      verify: (bloc) {
        verify(
          () => readTasksForDayUseCase.call(
            ReadTasksForDayUseCaseParams(dayId: sampleDayId),
          ),
        ).called(1);
      },
    );
    blocTest<TasksBloc, TasksState>(
      'State will be initially loading, with no tasks, then, if failure, will have an error message',
      build: () {
        when(
          () => readTasksForDayUseCase.call(any()),
        ).thenAnswer((_) async => left(LocalDatabaseFailure(readTasksError)));
        return bloc;
      },
      seed: () => TasksState(tasks: [], isLoading: false, error: null),
      act: (bloc) => bloc.add(ReadTasksForDayEvent(dayId: sampleDayId)),
      expect: () => [
        TasksState(tasks: [], isLoading: true, error: null),
        TasksState(tasks: [], isLoading: false, error: readTasksError),
      ],
      verify: (bloc) {
        verify(
          () => readTasksForDayUseCase.call(
            ReadTasksForDayUseCaseParams(dayId: sampleDayId),
          ),
        ).called(1);
      },
    );
  });

  group('Read tasks for a month', () {
    blocTest<TasksBloc, TasksState>(
      'Trying to read tasks for a month a while isLoading gives error',
      build: () {
        return bloc;
      },
      seed: () => TasksState(tasks: [], isLoading: true, error: null),
      act: (bloc) => bloc.add(ReadTasksForMonthEvent(monthId: '2025-08')),
      expect: () => [
        TasksState(
          tasks: [],
          isLoading: true,
          error: noOperationWhileIsLoadingError,
        ),
      ],
      verify: (bloc) {
        verifyZeroInteractions(readTasksForMonthUseCase);
      },
    );
    blocTest<TasksBloc, TasksState>(
      'State will be initially loading, with no tasks, then will have the month tasks if successful',
      build: () {
        when(
          () => readTasksForMonthUseCase.call(any()),
        ).thenAnswer((_) async => right([sampleTask1, sampleTask2]));
        return bloc;
      },
      seed: () => TasksState(tasks: [], isLoading: false, error: null),
      act: (bloc) => bloc.add(ReadTasksForMonthEvent(monthId: '2025-08')),
      expect: () => [
        TasksState(tasks: [], isLoading: true, error: null),
        TasksState(
          tasks: [sampleTask1, sampleTask2],
          isLoading: false,
          error: null,
        ),
      ],
      verify: (bloc) {
        verify(
          () => readTasksForMonthUseCase.call(
            ReadTasksForMonthUseCaseParams(monthId: '2025-08'),
          ),
        ).called(1);
      },
    );
    blocTest<TasksBloc, TasksState>(
      'State will be initially loading, with no tasks, then, if failure, will have an error message',
      build: () {
        when(
          () => readTasksForMonthUseCase.call(any()),
        ).thenAnswer((_) async => left(LocalDatabaseFailure(readTasksError)));
        return bloc;
      },
      seed: () => TasksState(tasks: [], isLoading: false, error: null),
      act: (bloc) => bloc.add(ReadTasksForMonthEvent(monthId: '2025-08')),
      expect: () => [
        TasksState(tasks: [], isLoading: true, error: null),
        TasksState(tasks: [], isLoading: false, error: readTasksError),
      ],
      verify: (bloc) {
        verify(
          () => readTasksForMonthUseCase.call(
            ReadTasksForMonthUseCaseParams(monthId: '2025-08'),
          ),
        ).called(1);
      },
    );
  });

  group('Update a task', () {
    blocTest<TasksBloc, TasksState>(
      'Trying to update a task while isLoading gives error',
      build: () {
        return bloc;
      },
      seed: () => TasksState(
        tasks: [sampleTask1, sampleTask2],
        isLoading: true,
        error: null,
      ),
      act: (bloc) => bloc.add(
        UpdateTaskEvent(
          taskId: sampleTask1.taskId,
          newCategoryId: sampleTask1.categoryId,
          newContent: 'updated 1',
          newIsRecurring: sampleTask1.isRecurring,
          newDiamonds: sampleTask1.diamonds,
        ),
      ),
      expect: () => [
        TasksState(
          tasks: [sampleTask1, sampleTask2],
          isLoading: true,
          error: noOperationWhileIsLoadingError,
        ),
      ],
      verify: (bloc) {
        verifyZeroInteractions(updateTaskUseCase);
      },
    );
    blocTest<TasksBloc, TasksState>(
      'Trying to update a task that is not present in currently visible tasks gives error',
      build: () {
        return bloc;
      },
      seed: () =>
          TasksState(tasks: [sampleTask2], isLoading: false, error: null),
      act: (bloc) => bloc.add(
        UpdateTaskEvent(
          taskId: sampleTask1.taskId,
          newCategoryId: sampleTask1.categoryId,
          newContent: 'updated 1',
          newIsRecurring: sampleTask1.isRecurring,
          newDiamonds: sampleTask1.diamonds,
        ),
      ),
      expect: () => [
        TasksState(tasks: [sampleTask2], isLoading: false, error: genericError),
      ],
      verify: (bloc) {
        verifyZeroInteractions(updateTaskUseCase);
      },
    );
    blocTest<TasksBloc, TasksState>(
      'Optimistically updates the task and emits state with isLoading false when successful',
      build: () {
        when(
          () => updateTaskUseCase.call(any()),
        ).thenAnswer((_) async => right(unit));
        return bloc;
      },
      seed: () => TasksState(
        tasks: [sampleTask1, sampleTask2],
        isLoading: false,
        error: null,
      ),
      act: (bloc) => bloc.add(
        UpdateTaskEvent(
          taskId: sampleTask1.taskId,
          newCategoryId: sampleTask1.categoryId,
          newContent: 'updated 1',
          newIsRecurring: sampleTask1.isRecurring,
          newDiamonds: sampleTask1.diamonds,
        ),
      ),
      expect: () => [
        TasksState(
          tasks: [
            sampleTask1.copyWith(content: 'updated 1'),
            sampleTask2,
          ],
          isLoading: true,
          error: null,
        ),
        TasksState(
          tasks: [
            sampleTask1.copyWith(content: 'updated 1'),
            sampleTask2,
          ],
          isLoading: false,
          error: null,
        ),
      ],
      verify: (bloc) {
        verify(
          () => updateTaskUseCase.call(
            UpdateTaskUseCaseParams(
              taskId: sampleTask1.taskId,
              categoryId: sampleTask1.categoryId,
              content: 'updated 1',
              isRecurring: sampleTask1.isRecurring,
              diamonds: sampleTask1.diamonds,
            ),
          ),
        ).called(1);
      },
    );
    blocTest<TasksBloc, TasksState>(
      'Optimistically updates the task, reverts it when failure and emits error',
      build: () {
        when(
          () => updateTaskUseCase.call(any()),
        ).thenAnswer((_) async => left(LocalDatabaseFailure(updateTaskError)));
        return bloc;
      },
      seed: () => TasksState(
        tasks: [sampleTask1, sampleTask2],
        isLoading: false,
        error: null,
      ),
      act: (bloc) => bloc.add(
        UpdateTaskEvent(
          taskId: sampleTask1.taskId,
          newCategoryId: sampleTask1.categoryId,
          newContent: 'updated 1',
          newIsRecurring: sampleTask1.isRecurring,
          newDiamonds: sampleTask1.diamonds,
        ),
      ),
      expect: () => [
        TasksState(
          tasks: [
            sampleTask1.copyWith(content: 'updated 1'),
            sampleTask2,
          ],
          isLoading: true,
          error: null,
        ),
        TasksState(
          tasks: [sampleTask1, sampleTask2],
          isLoading: false,
          error: updateTaskError,
        ),
      ],
    );
  });

  group('Delete a task', () {
    blocTest<TasksBloc, TasksState>(
      'Trying to delete a task while isLoading gives error',
      build: () {
        return bloc;
      },
      seed: () => TasksState(
        tasks: [sampleTask1, sampleTask2],
        isLoading: true,
        error: null,
      ),
      act: (bloc) => bloc.add(
        DeleteTaskEvent(dayId: sampleDayId, taskId: sampleTask1.taskId),
      ),
      expect: () => [
        TasksState(
          tasks: [sampleTask1, sampleTask2],
          isLoading: true,
          error: noOperationWhileIsLoadingError,
        ),
      ],
      verify: (bloc) {
        verifyZeroInteractions(deleteTaskUseCase);
      },
    );
    blocTest<TasksBloc, TasksState>(
      'Trying to delete a task that is not present in currently visible tasks gives error',
      build: () {
        return bloc;
      },
      seed: () =>
          TasksState(tasks: [sampleTask2], isLoading: false, error: null),
      act: (bloc) => bloc.add(
        DeleteTaskEvent(dayId: sampleDayId, taskId: sampleTask1.taskId),
      ),
      expect: () => [
        TasksState(tasks: [sampleTask2], isLoading: false, error: genericError),
      ],
      verify: (bloc) {
        verifyZeroInteractions(deleteTaskUseCase);
      },
    );
    blocTest<TasksBloc, TasksState>(
      'Optimistically deletes the task and emits state with isLoading false when successful',
      build: () {
        when(
          () => deleteTaskUseCase.call(any()),
        ).thenAnswer((_) async => right(unit));
        return bloc;
      },
      seed: () => TasksState(
        tasks: [sampleTask1, sampleTask2],
        isLoading: false,
        error: null,
      ),
      act: (bloc) => bloc.add(
        DeleteTaskEvent(dayId: sampleDayId, taskId: sampleTask1.taskId),
      ),
      expect: () => [
        TasksState(tasks: [sampleTask2], isLoading: true, error: null),
        TasksState(tasks: [sampleTask2], isLoading: false, error: null),
      ],
      verify: (bloc) {
        verify(
          () => deleteTaskUseCase.call(
            DeleteTaskUseCaseParams(
              dayId: sampleDayId,
              taskId: sampleTask1.taskId,
              isRecurring: sampleTask1.isRecurring,
            ),
          ),
        );
      },
    );
    blocTest<TasksBloc, TasksState>(
      'Optimistically deletes the task, reverts it when failure and emits error',
      build: () {
        when(
          () => deleteTaskUseCase.call(any()),
        ).thenAnswer((_) async => left(LocalDatabaseFailure(deleteTaskError)));
        return bloc;
      },
      seed: () => TasksState(
        tasks: [sampleTask1, sampleTask2],
        isLoading: false,
        error: null,
      ),
      act: (bloc) => bloc.add(
        DeleteTaskEvent(dayId: sampleDayId, taskId: sampleTask1.taskId),
      ),
      expect: () => [
        TasksState(tasks: [sampleTask2], isLoading: true, error: null),
        TasksState(
          tasks: [sampleTask1, sampleTask2],
          isLoading: false,
          error: deleteTaskError,
        ),
      ],
      verify: (bloc) {
        verify(
          () => deleteTaskUseCase.call(
            DeleteTaskUseCaseParams(
              dayId: sampleDayId,
              taskId: sampleTask1.taskId,
              isRecurring: sampleTask1.isRecurring,
            ),
          ),
        );
      },
    );
  });

  group('Set a task', () {
    blocTest<TasksBloc, TasksState>(
      'Trying to set a task while isLoading gives error',
      build: () {
        return bloc;
      },
      seed: () => TasksState(
        tasks: [sampleTask1, sampleTask2],
        isLoading: true,
        error: null,
      ),
      act: (bloc) => bloc.add(
        SetTaskEvent(
          dayId: sampleDayId,
          taskId: sampleTask1.taskId,
          completed: true,
        ),
      ),
      expect: () => [
        TasksState(
          tasks: [sampleTask1, sampleTask2],
          isLoading: true,
          error: noOperationWhileIsLoadingError,
        ),
      ],
      verify: (bloc) {
        verifyZeroInteractions(deleteTaskUseCase);
      },
    );
    blocTest<TasksBloc, TasksState>(
      'Trying to set a task that is not present in currently visible tasks gives error',
      build: () {
        return bloc;
      },
      seed: () =>
          TasksState(tasks: [sampleTask2], isLoading: false, error: null),
      act: (bloc) => bloc.add(
        SetTaskEvent(
          dayId: sampleDayId,
          taskId: sampleTask1.taskId,
          completed: true,
        ),
      ),
      expect: () => [
        TasksState(tasks: [sampleTask2], isLoading: false, error: genericError),
      ],
      verify: (bloc) {
        verifyZeroInteractions(setTaskUseCase);
      },
    );
    blocTest<TasksBloc, TasksState>(
      'Optimistically sets the task and emits state with isLoading false when successful',
      build: () {
        when(() => setTaskUseCase(any())).thenAnswer((_) async => right(unit));
        return bloc;
      },
      seed: () => TasksState(
        tasks: [sampleTask1, sampleTask2],
        isLoading: false,
        error: null,
      ),
      act: (bloc) => bloc.add(
        SetTaskEvent(
          dayId: sampleDayId,
          taskId: sampleTask1.taskId,
          completed: true,
        ),
      ),
      expect: () => [
        TasksState(
          tasks: [sampleTask1.copyWith(isDone: true), sampleTask2],
          isLoading: true,
          error: null,
        ),
        TasksState(
          tasks: [sampleTask1.copyWith(isDone: true), sampleTask2],
          isLoading: false,
          error: null,
        ),
      ],
      verify: (bloc) {
        verify(
          () => setTaskUseCase(
            SetTaskUseCaseParams(
              dayId: sampleDayId,
              taskId: sampleTask1.taskId,
              completed: true,
            ),
          ),
        ).called(1);
      },
    );
    blocTest<TasksBloc, TasksState>(
      'Optimistically sets the task, reverts it when failure and emits error',
      build: () {
        when(
          () => setTaskUseCase(any()),
        ).thenAnswer((_) async => left(LocalDatabaseFailure(updateTaskError)));
        return bloc;
      },
      seed: () => TasksState(
        tasks: [sampleTask1, sampleTask2],
        isLoading: false,
        error: null,
      ),
      act: (bloc) => bloc.add(
        SetTaskEvent(
          dayId: sampleDayId,
          taskId: sampleTask1.taskId,
          completed: true,
        ),
      ),
      expect: () => [
        TasksState(
          tasks: [sampleTask1.copyWith(isDone: true), sampleTask2],
          isLoading: true,
          error: null,
        ),
        TasksState(
          tasks: [sampleTask1, sampleTask2],
          isLoading: false,
          error: updateTaskError,
        ),
      ],
      verify: (bloc) {
        verify(
          () => setTaskUseCase(
            SetTaskUseCaseParams(
              dayId: sampleDayId,
              taskId: sampleTask1.taskId,
              completed: true,
            ),
          ),
        ).called(1);
      },
    );
  });
}
