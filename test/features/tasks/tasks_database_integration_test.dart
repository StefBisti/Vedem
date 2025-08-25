import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:async/src/stream_queue.dart';
import 'package:vedem/core/database/database_keys.dart';
import 'package:vedem/core/error/error_messages.dart';
import 'package:vedem/features/tasks/data/datasources/task_local_data_source.dart';
import 'package:vedem/features/tasks/data/models/task_model.dart';
import 'package:vedem/features/tasks/data/repositories/task_repository_impl.dart';
import 'package:vedem/features/tasks/domain/entities/task_entity.dart';
import 'package:vedem/features/tasks/presentation/bloc/tasks_bloc.dart';
import 'delayed_usecases/delayed_usecases.dart';

void main() {
  late Database db;
  late TaskLocalDataSource dataSource;
  late TaskRepositoryImpl repo;
  late DelayedCreateNewTaskUseCase createNewTaskUseCase;
  late DelayedDeleteTaskUseCase deleteTaskUseCase;
  late DelayedInitializeTasksForDayUseCase initializeTasksForDayUseCase;
  late DelayedReadTasksForDayUseCase readTasksForDayUseCase;
  late DelayedReadTasksForMonthUseCase readTasksForMonthUseCase;
  late DelayedSetTaskUseCase setTaskUseCase;
  late DelayedUpdateTaskUseCase updateTaskUseCase;
  late TasksBloc bloc;

  setUpAll(() {
    sqfliteFfiInit();
  });

  setUp(() async {
    db = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE ${TasksTableKeys.tasksTableKey} (
              ${TasksTableKeys.taskIdKey} INTEGER PRIMARY KEY AUTOINCREMENT,
              ${TasksTableKeys.taskCategoryIdKey} INTEGER NOT NULL,
              ${TasksTableKeys.taskContentKey} TEXT NOT NULL,
              ${TasksTableKeys.taskIsRecurringKey} INTEGER NOT NULL,
              ${TasksTableKeys.taskDiamondsKey} INTEGER NOT NULL
            )
          ''');
          await db.execute('''
            CREATE TABLE ${DayTasksTableKeys.dayTasksTableKey} (
              ${DayTasksTableKeys.dayTaskIdKey} INTEGER PRIMARY KEY AUTOINCREMENT,
              ${DayTasksTableKeys.dayTaskDayKey} TEXT NOT NULL,
              ${DayTasksTableKeys.dayTaskTaskKey} INTEGER NOT NULL,
              ${DayTasksTableKeys.dayTaskDoneKey} INTEGER NOT NULL DEFAULT 0,
              FOREIGN KEY (${DayTasksTableKeys.dayTaskTaskKey}) REFERENCES ${TasksTableKeys.tasksTableKey} (${TasksTableKeys.taskIdKey})
            );
          ''');
          await db.execute(
            'CREATE INDEX idx_tasks_category_id ON ${TasksTableKeys.tasksTableKey}(${TasksTableKeys.taskCategoryIdKey});',
          );
          await db.execute(
            'CREATE INDEX idx_day_tasks_task_id ON ${DayTasksTableKeys.dayTasksTableKey}(${DayTasksTableKeys.dayTaskTaskKey});',
          );
          await db.execute(
            'CREATE INDEX idx_day_tasks_day_id ON ${DayTasksTableKeys.dayTasksTableKey}(${DayTasksTableKeys.dayTaskDayKey});',
          );
        },
      ),
    );
    dataSource = TaskLocalDataSource(db: db);
    repo = TaskRepositoryImpl(dataSource: dataSource);
    createNewTaskUseCase = DelayedCreateNewTaskUseCase(taskRepository: repo);
    initializeTasksForDayUseCase = DelayedInitializeTasksForDayUseCase(
      taskRepository: repo,
    );
    readTasksForDayUseCase = DelayedReadTasksForDayUseCase(
      taskRepository: repo,
    );
    readTasksForMonthUseCase = DelayedReadTasksForMonthUseCase(
      taskRepository: repo,
    );
    updateTaskUseCase = DelayedUpdateTaskUseCase(taskRepository: repo);
    deleteTaskUseCase = DelayedDeleteTaskUseCase(taskRepository: repo);
    setTaskUseCase = DelayedSetTaskUseCase(taskRepository: repo);
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

  tearDown(() async {
    await bloc.close();
    await db.close();
  });

  final TaskEntity sampleTask1 = TaskEntity(
    taskId: 1,
    categoryId: 1,
    content: 'test 1',
    isRecurring: false,
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
  final TaskEntity sampleTask3 = TaskEntity(
    taskId: 3,
    categoryId: 3,
    content: 'test 3',
    isRecurring: true,
    diamonds: 33,
    isDone: false,
  );
  final TaskEntity sampleTask4 = TaskEntity(
    taskId: 4,
    categoryId: 4,
    content: 'test 4',
    isRecurring: true,
    diamonds: 44,
    isDone: false,
  );
  final String sampleDayId1 = '2025-08-23';
  final String sampleDayId2 = '2025-08-24';
  final String sampleMonthId1 = '2025-08';
  final String sampleMonthId2 = '2025-09';

  group('Initializing a day', () {
    test(
      'When no tasks in the db, the return should be an empty list and nothing added to the db',
      () async {
        final tasksRows = await db.query('tasks');
        final dayTasksRows = await db.query('day_tasks');
        expect(tasksRows.length, 0);
        expect(dayTasksRows.length, 0);

        final queue = StreamQueue<TasksState>(bloc.stream);
        bloc.add(InitializeTasksForDayEvent(dayId: sampleDayId1));

        final first = await queue.next;
        expect(first, TasksState(tasks: [], isLoading: true, error: null));

        final second = await queue.next;
        expect(second, TasksState(tasks: [], isLoading: false, error: null));

        final tasksRows1 = await db.query('tasks');
        final dayTasksRows1 = await db.query('day_tasks');
        expect(tasksRows1.length, 0);
        expect(dayTasksRows1.length, 0);

        await queue.cancel();
      },
    );
    test(
      'When only non-recurring tasks in the db, the return should be empty, nothing added to the db',
      () async {
        await db.insert(TasksTableKeys.tasksTableKey, {
          TasksTableKeys.taskCategoryIdKey: sampleTask1.taskId,
          TasksTableKeys.taskContentKey: sampleTask1.content,
          TasksTableKeys.taskIsRecurringKey: sampleTask1.isRecurring ? 1 : 0,
          TasksTableKeys.taskDiamondsKey: sampleTask1.diamonds,
        });
        await db.insert(TasksTableKeys.tasksTableKey, {
          TasksTableKeys.taskCategoryIdKey: sampleTask2.taskId,
          TasksTableKeys.taskContentKey: sampleTask2.content,
          TasksTableKeys.taskIsRecurringKey: sampleTask2.isRecurring ? 1 : 0,
          TasksTableKeys.taskDiamondsKey: sampleTask2.diamonds,
        });

        final tasksRows = await db.query('tasks');
        final dayTasksRows = await db.query('day_tasks');
        expect(tasksRows.length, 2);
        expect(dayTasksRows.length, 0);

        final queue = StreamQueue<TasksState>(bloc.stream);
        bloc.add(InitializeTasksForDayEvent(dayId: sampleDayId1));

        final first = await queue.next;
        expect(first, TasksState(tasks: [], isLoading: true, error: null));

        final second = await queue.next;
        expect(second, TasksState(tasks: [], isLoading: false, error: null));

        final tasksRows1 = await db.query('tasks');
        final dayTasksRows1 = await db.query('day_tasks');
        expect(tasksRows1.length, 2);
        expect(dayTasksRows1.length, 0);

        await queue.cancel();
      },
    );
    test(
      'When only recurring tasks in the db, the return should be those recurring tasks, they are added to the db',
      () async {
        await db.insert(TasksTableKeys.tasksTableKey, {
          TasksTableKeys.taskIdKey: sampleTask3.taskId,
          TasksTableKeys.taskCategoryIdKey: sampleTask3.categoryId,
          TasksTableKeys.taskContentKey: sampleTask3.content,
          TasksTableKeys.taskIsRecurringKey: sampleTask3.isRecurring ? 1 : 0,
          TasksTableKeys.taskDiamondsKey: sampleTask3.diamonds,
        });
        await db.insert(TasksTableKeys.tasksTableKey, {
          TasksTableKeys.taskIdKey: sampleTask4.taskId,
          TasksTableKeys.taskCategoryIdKey: sampleTask4.categoryId,
          TasksTableKeys.taskContentKey: sampleTask4.content,
          TasksTableKeys.taskIsRecurringKey: sampleTask4.isRecurring ? 1 : 0,
          TasksTableKeys.taskDiamondsKey: sampleTask4.diamonds,
        });

        final tasksRows = await db.query('tasks');
        final dayTasksRows = await db.query('day_tasks');
        expect(tasksRows.length, 2);
        expect(dayTasksRows.length, 0);

        final queue = StreamQueue<TasksState>(bloc.stream);
        bloc.add(InitializeTasksForDayEvent(dayId: sampleDayId1));

        final first = await queue.next;
        expect(first, TasksState(tasks: [], isLoading: true, error: null));

        final second = await queue.next;
        expect(
          second,
          TasksState(
            tasks: [sampleTask3, sampleTask4],
            isLoading: false,
            error: null,
          ),
        );

        final tasksRows1 = await db.query('tasks');
        final dayTasksRows1 = await db.query('day_tasks');
        expect(tasksRows1.length, 2);
        expect(dayTasksRows1.length, 2);

        await queue.cancel();
      },
    );
    test(
      'When both recurring and non-recurring tasks in the db, the return should be those recurring tasks, they are added to the db',
      () async {
        await db.insert(TasksTableKeys.tasksTableKey, {
          TasksTableKeys.taskIdKey: sampleTask1.taskId,
          TasksTableKeys.taskCategoryIdKey: sampleTask1.categoryId,
          TasksTableKeys.taskContentKey: sampleTask1.content,
          TasksTableKeys.taskIsRecurringKey: sampleTask1.isRecurring ? 1 : 0,
          TasksTableKeys.taskDiamondsKey: sampleTask1.diamonds,
        });
        await db.insert(TasksTableKeys.tasksTableKey, {
          TasksTableKeys.taskIdKey: sampleTask2.taskId,
          TasksTableKeys.taskCategoryIdKey: sampleTask2.categoryId,
          TasksTableKeys.taskContentKey: sampleTask2.content,
          TasksTableKeys.taskIsRecurringKey: sampleTask2.isRecurring ? 1 : 0,
          TasksTableKeys.taskDiamondsKey: sampleTask2.diamonds,
        });
        await db.insert(TasksTableKeys.tasksTableKey, {
          TasksTableKeys.taskIdKey: sampleTask3.taskId,
          TasksTableKeys.taskCategoryIdKey: sampleTask3.categoryId,
          TasksTableKeys.taskContentKey: sampleTask3.content,
          TasksTableKeys.taskIsRecurringKey: sampleTask3.isRecurring ? 1 : 0,
          TasksTableKeys.taskDiamondsKey: sampleTask3.diamonds,
        });
        await db.insert(TasksTableKeys.tasksTableKey, {
          TasksTableKeys.taskIdKey: sampleTask4.taskId,
          TasksTableKeys.taskCategoryIdKey: sampleTask4.categoryId,
          TasksTableKeys.taskContentKey: sampleTask4.content,
          TasksTableKeys.taskIsRecurringKey: sampleTask4.isRecurring ? 1 : 0,
          TasksTableKeys.taskDiamondsKey: sampleTask4.diamonds,
        });

        final tasksRows = await db.query('tasks');
        final dayTasksRows = await db.query('day_tasks');
        expect(tasksRows.length, 4);
        expect(dayTasksRows.length, 0);

        final queue = StreamQueue<TasksState>(bloc.stream);
        bloc.add(InitializeTasksForDayEvent(dayId: sampleDayId1));

        final first = await queue.next;
        expect(first, TasksState(tasks: [], isLoading: true, error: null));

        final second = await queue.next;
        expect(
          second,
          TasksState(
            tasks: [sampleTask3, sampleTask4],
            isLoading: false,
            error: null,
          ),
        );

        final tasksRows1 = await db.query('tasks');
        final dayTasksRows1 = await db.query('day_tasks');
        expect(tasksRows1.length, 4);
        expect(dayTasksRows1.length, 2);

        await queue.cancel();
      },
    );
  });

  group('Reading the tasks for a day', () {
    test(
      'When no tasks in db, the return should be an empty list, nothing added to the db',
      () async {
        final tasksRows = await db.query('tasks');
        final dayTasksRows = await db.query('day_tasks');
        expect(tasksRows.length, 0);
        expect(dayTasksRows.length, 0);

        final queue = StreamQueue<TasksState>(bloc.stream);
        bloc.add(ReadTasksForDayEvent(dayId: sampleDayId1));

        final first = await queue.next;
        expect(first, TasksState(tasks: [], isLoading: true, error: null));

        final second = await queue.next;
        expect(second, TasksState(tasks: [], isLoading: false, error: null));

        final tasksRows1 = await db.query('tasks');
        final dayTasksRows1 = await db.query('day_tasks');
        expect(tasksRows1.length, 0);
        expect(dayTasksRows1.length, 0);

        await queue.cancel();
      },
    );
    test(
      'When no tasks in db for the selected day, the return should be empty, nothing added to the db',
      () async {
        await db.insert(TasksTableKeys.tasksTableKey, {
          TasksTableKeys.taskIdKey: sampleTask1.taskId,
          TasksTableKeys.taskCategoryIdKey: sampleTask1.categoryId,
          TasksTableKeys.taskContentKey: sampleTask1.content,
          TasksTableKeys.taskIsRecurringKey: sampleTask1.isRecurring ? 1 : 0,
          TasksTableKeys.taskDiamondsKey: sampleTask1.diamonds,
        });
        await db.insert(TasksTableKeys.tasksTableKey, {
          TasksTableKeys.taskIdKey: sampleTask2.taskId,
          TasksTableKeys.taskCategoryIdKey: sampleTask2.categoryId,
          TasksTableKeys.taskContentKey: sampleTask2.content,
          TasksTableKeys.taskIsRecurringKey: sampleTask2.isRecurring ? 1 : 0,
          TasksTableKeys.taskDiamondsKey: sampleTask2.diamonds,
        });
        await db.insert(DayTasksTableKeys.dayTasksTableKey, {
          DayTasksTableKeys.dayTaskDayKey: sampleDayId1,
          DayTasksTableKeys.dayTaskTaskKey: sampleTask1.taskId,
          DayTasksTableKeys.dayTaskDoneKey: 0,
        });
        await db.insert(DayTasksTableKeys.dayTasksTableKey, {
          DayTasksTableKeys.dayTaskDayKey: sampleDayId1,
          DayTasksTableKeys.dayTaskTaskKey: sampleTask2.taskId,
          DayTasksTableKeys.dayTaskDoneKey: 0,
        });

        final tasksRows = await db.query('tasks');
        final dayTasksRows = await db.query('day_tasks');
        expect(tasksRows.length, 2);
        expect(dayTasksRows.length, 2);

        final queue = StreamQueue<TasksState>(bloc.stream);
        bloc.add(ReadTasksForDayEvent(dayId: sampleDayId2));

        final first = await queue.next;
        expect(first, TasksState(tasks: [], isLoading: true, error: null));

        final second = await queue.next;
        expect(second, TasksState(tasks: [], isLoading: false, error: null));

        final tasksRows1 = await db.query('tasks');
        final dayTasksRows1 = await db.query('day_tasks');
        expect(tasksRows1.length, 2);
        expect(dayTasksRows1.length, 2);

        await queue.cancel();
      },
    );
    test(
      'When there are tasks for both the selected day and other day, the return should contain the selected day\'s tasks',
      () async {
        await db.insert(TasksTableKeys.tasksTableKey, {
          TasksTableKeys.taskIdKey: sampleTask1.taskId,
          TasksTableKeys.taskCategoryIdKey: sampleTask1.categoryId,
          TasksTableKeys.taskContentKey: sampleTask1.content,
          TasksTableKeys.taskIsRecurringKey: sampleTask1.isRecurring ? 1 : 0,
          TasksTableKeys.taskDiamondsKey: sampleTask1.diamonds,
        });
        await db.insert(TasksTableKeys.tasksTableKey, {
          TasksTableKeys.taskIdKey: sampleTask2.taskId,
          TasksTableKeys.taskCategoryIdKey: sampleTask2.categoryId,
          TasksTableKeys.taskContentKey: sampleTask2.content,
          TasksTableKeys.taskIsRecurringKey: sampleTask2.isRecurring ? 1 : 0,
          TasksTableKeys.taskDiamondsKey: sampleTask2.diamonds,
        });
        await db.insert(DayTasksTableKeys.dayTasksTableKey, {
          DayTasksTableKeys.dayTaskDayKey: sampleDayId1,
          DayTasksTableKeys.dayTaskTaskKey: sampleTask1.taskId,
          DayTasksTableKeys.dayTaskDoneKey: 0,
        });
        await db.insert(DayTasksTableKeys.dayTasksTableKey, {
          DayTasksTableKeys.dayTaskDayKey: sampleDayId2,
          DayTasksTableKeys.dayTaskTaskKey: sampleTask2.taskId,
          DayTasksTableKeys.dayTaskDoneKey: 0,
        });

        final tasksRows = await db.query('tasks');
        final dayTasksRows = await db.query('day_tasks');
        expect(tasksRows.length, 2);
        expect(dayTasksRows.length, 2);

        final queue = StreamQueue<TasksState>(bloc.stream);
        bloc.add(ReadTasksForDayEvent(dayId: sampleDayId2));

        final first = await queue.next;
        expect(first, TasksState(tasks: [], isLoading: true, error: null));

        final second = await queue.next;
        expect(
          second,
          TasksState(tasks: [sampleTask2], isLoading: false, error: null),
        );

        final tasksRows1 = await db.query('tasks');
        final dayTasksRows1 = await db.query('day_tasks');
        expect(tasksRows1.length, 2);
        expect(dayTasksRows1.length, 2);

        await queue.cancel();
      },
    );
    test('When no corresponding task id, simply skip it', () async {
      await db.insert(TasksTableKeys.tasksTableKey, {
        TasksTableKeys.taskIdKey: sampleTask1.taskId,
        TasksTableKeys.taskCategoryIdKey: sampleTask1.categoryId,
        TasksTableKeys.taskContentKey: sampleTask1.content,
        TasksTableKeys.taskIsRecurringKey: sampleTask1.isRecurring ? 1 : 0,
        TasksTableKeys.taskDiamondsKey: sampleTask1.diamonds,
      });
      await db.insert(TasksTableKeys.tasksTableKey, {
        TasksTableKeys.taskIdKey: sampleTask2.taskId,
        TasksTableKeys.taskCategoryIdKey: sampleTask2.categoryId,
        TasksTableKeys.taskContentKey: sampleTask2.content,
        TasksTableKeys.taskIsRecurringKey: sampleTask2.isRecurring ? 1 : 0,
        TasksTableKeys.taskDiamondsKey: sampleTask2.diamonds,
      });
      await db.insert(DayTasksTableKeys.dayTasksTableKey, {
        DayTasksTableKeys.dayTaskDayKey: sampleDayId1,
        DayTasksTableKeys.dayTaskTaskKey: sampleTask1.taskId,
        DayTasksTableKeys.dayTaskDoneKey: 0,
      });
      await db.insert(DayTasksTableKeys.dayTasksTableKey, {
        DayTasksTableKeys.dayTaskDayKey: sampleDayId1,
        DayTasksTableKeys.dayTaskTaskKey: sampleTask2.taskId,
        DayTasksTableKeys.dayTaskDoneKey: 0,
      });
      await db.insert(DayTasksTableKeys.dayTasksTableKey, {
        DayTasksTableKeys.dayTaskDayKey: sampleDayId1,
        DayTasksTableKeys.dayTaskTaskKey: sampleTask3.taskId,
        DayTasksTableKeys.dayTaskDoneKey: 0,
      });

      final tasksRows = await db.query('tasks');
      final dayTasksRows = await db.query('day_tasks');
      expect(tasksRows.length, 2);
      expect(dayTasksRows.length, 3);

      final queue = StreamQueue<TasksState>(bloc.stream);
      bloc.add(ReadTasksForDayEvent(dayId: sampleDayId1));

      final first = await queue.next;
      expect(first, TasksState(tasks: [], isLoading: true, error: null));

      final second = await queue.next;
      expect(
        second,
        TasksState(
          tasks: [sampleTask1, sampleTask2],
          isLoading: false,
          error: null,
        ),
      );

      final tasksRows1 = await db.query('tasks');
      final dayTasksRows1 = await db.query('day_tasks');
      expect(tasksRows1.length, 2);
      expect(dayTasksRows1.length, 3);

      await queue.cancel();
    });
  });

  group('Reading the tasks for a month', () {
    test(
      'When no tasks in db, the return should be an empty list, nothing added to the db',
      () async {
        final tasksRows = await db.query('tasks');
        final dayTasksRows = await db.query('day_tasks');
        expect(tasksRows.length, 0);
        expect(dayTasksRows.length, 0);

        final queue = StreamQueue<TasksState>(bloc.stream);
        bloc.add(ReadTasksForMonthEvent(monthId: sampleMonthId1));

        final first = await queue.next;
        expect(first, TasksState(tasks: [], isLoading: true, error: null));

        final second = await queue.next;
        expect(second, TasksState(tasks: [], isLoading: false, error: null));

        final tasksRows1 = await db.query('tasks');
        final dayTasksRows1 = await db.query('day_tasks');
        expect(tasksRows1.length, 0);
        expect(dayTasksRows1.length, 0);

        await queue.cancel();
      },
    );
    test(
      'When no tasks in db for the selected month, the return should be empty, nothing added to the db',
      () async {
        await db.insert(TasksTableKeys.tasksTableKey, {
          TasksTableKeys.taskIdKey: sampleTask1.taskId,
          TasksTableKeys.taskCategoryIdKey: sampleTask1.categoryId,
          TasksTableKeys.taskContentKey: sampleTask1.content,
          TasksTableKeys.taskIsRecurringKey: sampleTask1.isRecurring ? 1 : 0,
          TasksTableKeys.taskDiamondsKey: sampleTask1.diamonds,
        });
        await db.insert(TasksTableKeys.tasksTableKey, {
          TasksTableKeys.taskIdKey: sampleTask2.taskId,
          TasksTableKeys.taskCategoryIdKey: sampleTask2.categoryId,
          TasksTableKeys.taskContentKey: sampleTask2.content,
          TasksTableKeys.taskIsRecurringKey: sampleTask2.isRecurring ? 1 : 0,
          TasksTableKeys.taskDiamondsKey: sampleTask2.diamonds,
        });
        await db.insert(DayTasksTableKeys.dayTasksTableKey, {
          DayTasksTableKeys.dayTaskDayKey: sampleDayId1,
          DayTasksTableKeys.dayTaskTaskKey: sampleTask1.taskId,
          DayTasksTableKeys.dayTaskDoneKey: 0,
        });
        await db.insert(DayTasksTableKeys.dayTasksTableKey, {
          DayTasksTableKeys.dayTaskDayKey: sampleDayId1,
          DayTasksTableKeys.dayTaskTaskKey: sampleTask2.taskId,
          DayTasksTableKeys.dayTaskDoneKey: 0,
        });

        final tasksRows = await db.query('tasks');
        final dayTasksRows = await db.query('day_tasks');
        expect(tasksRows.length, 2);
        expect(dayTasksRows.length, 2);

        final queue = StreamQueue<TasksState>(bloc.stream);
        bloc.add(ReadTasksForMonthEvent(monthId: sampleMonthId2));

        final first = await queue.next;
        expect(first, TasksState(tasks: [], isLoading: true, error: null));

        final second = await queue.next;
        expect(second, TasksState(tasks: [], isLoading: false, error: null));

        final tasksRows1 = await db.query('tasks');
        final dayTasksRows1 = await db.query('day_tasks');
        expect(tasksRows1.length, 2);
        expect(dayTasksRows1.length, 2);

        await queue.cancel();
      },
    );
    test(
      'When there are tasks for both the selected month and other month, the return should contain the selected month\'s tasks',
      () async {
        await db.insert(TasksTableKeys.tasksTableKey, {
          TasksTableKeys.taskIdKey: sampleTask1.taskId,
          TasksTableKeys.taskCategoryIdKey: sampleTask1.categoryId,
          TasksTableKeys.taskContentKey: sampleTask1.content,
          TasksTableKeys.taskIsRecurringKey: sampleTask1.isRecurring ? 1 : 0,
          TasksTableKeys.taskDiamondsKey: sampleTask1.diamonds,
        });
        await db.insert(TasksTableKeys.tasksTableKey, {
          TasksTableKeys.taskIdKey: sampleTask2.taskId,
          TasksTableKeys.taskCategoryIdKey: sampleTask2.categoryId,
          TasksTableKeys.taskContentKey: sampleTask2.content,
          TasksTableKeys.taskIsRecurringKey: sampleTask2.isRecurring ? 1 : 0,
          TasksTableKeys.taskDiamondsKey: sampleTask2.diamonds,
        });
        await db.insert(DayTasksTableKeys.dayTasksTableKey, {
          DayTasksTableKeys.dayTaskDayKey: '2025-09-10',
          DayTasksTableKeys.dayTaskTaskKey: sampleTask1.taskId,
          DayTasksTableKeys.dayTaskDoneKey: 0,
        });
        await db.insert(DayTasksTableKeys.dayTasksTableKey, {
          DayTasksTableKeys.dayTaskDayKey: sampleDayId2,
          DayTasksTableKeys.dayTaskTaskKey: sampleTask2.taskId,
          DayTasksTableKeys.dayTaskDoneKey: 0,
        });

        final tasksRows = await db.query('tasks');
        final dayTasksRows = await db.query('day_tasks');
        expect(tasksRows.length, 2);
        expect(dayTasksRows.length, 2);

        final queue = StreamQueue<TasksState>(bloc.stream);
        bloc.add(ReadTasksForMonthEvent(monthId: sampleMonthId1));

        final first = await queue.next;
        expect(first, TasksState(tasks: [], isLoading: true, error: null));

        final second = await queue.next;
        expect(
          second,
          TasksState(tasks: [sampleTask2], isLoading: false, error: null),
        );

        final tasksRows1 = await db.query('tasks');
        final dayTasksRows1 = await db.query('day_tasks');
        expect(tasksRows1.length, 2);
        expect(dayTasksRows1.length, 2);

        await queue.cancel();
      },
    );
    test('When no corresponding task id, simply skip it', () async {
      await db.insert(TasksTableKeys.tasksTableKey, {
        TasksTableKeys.taskIdKey: sampleTask1.taskId,
        TasksTableKeys.taskCategoryIdKey: sampleTask1.categoryId,
        TasksTableKeys.taskContentKey: sampleTask1.content,
        TasksTableKeys.taskIsRecurringKey: sampleTask1.isRecurring ? 1 : 0,
        TasksTableKeys.taskDiamondsKey: sampleTask1.diamonds,
      });
      await db.insert(TasksTableKeys.tasksTableKey, {
        TasksTableKeys.taskIdKey: sampleTask2.taskId,
        TasksTableKeys.taskCategoryIdKey: sampleTask2.categoryId,
        TasksTableKeys.taskContentKey: sampleTask2.content,
        TasksTableKeys.taskIsRecurringKey: sampleTask2.isRecurring ? 1 : 0,
        TasksTableKeys.taskDiamondsKey: sampleTask2.diamonds,
      });
      await db.insert(DayTasksTableKeys.dayTasksTableKey, {
        DayTasksTableKeys.dayTaskDayKey: sampleDayId1,
        DayTasksTableKeys.dayTaskTaskKey: sampleTask1.taskId,
        DayTasksTableKeys.dayTaskDoneKey: 0,
      });
      await db.insert(DayTasksTableKeys.dayTasksTableKey, {
        DayTasksTableKeys.dayTaskDayKey: sampleDayId1,
        DayTasksTableKeys.dayTaskTaskKey: sampleTask2.taskId,
        DayTasksTableKeys.dayTaskDoneKey: 0,
      });
      await db.insert(DayTasksTableKeys.dayTasksTableKey, {
        DayTasksTableKeys.dayTaskDayKey: sampleDayId1,
        DayTasksTableKeys.dayTaskTaskKey: sampleTask3.taskId,
        DayTasksTableKeys.dayTaskDoneKey: 0,
      });

      final tasksRows = await db.query('tasks');
      final dayTasksRows = await db.query('day_tasks');
      expect(tasksRows.length, 2);
      expect(dayTasksRows.length, 3);

      final queue = StreamQueue<TasksState>(bloc.stream);
      bloc.add(ReadTasksForMonthEvent(monthId: sampleMonthId1));

      final first = await queue.next;
      expect(first, TasksState(tasks: [], isLoading: true, error: null));

      final second = await queue.next;
      expect(
        second,
        TasksState(
          tasks: [sampleTask1, sampleTask2],
          isLoading: false,
          error: null,
        ),
      );

      final tasksRows1 = await db.query('tasks');
      final dayTasksRows1 = await db.query('day_tasks');
      expect(tasksRows1.length, 2);
      expect(dayTasksRows1.length, 3);

      await queue.cancel();
    });
    test('Reading tasks for december works as expected', () async {
      await db.insert(TasksTableKeys.tasksTableKey, {
        TasksTableKeys.taskIdKey: sampleTask1.taskId,
        TasksTableKeys.taskCategoryIdKey: sampleTask1.categoryId,
        TasksTableKeys.taskContentKey: sampleTask1.content,
        TasksTableKeys.taskIsRecurringKey: sampleTask1.isRecurring ? 1 : 0,
        TasksTableKeys.taskDiamondsKey: sampleTask1.diamonds,
      });
      await db.insert(TasksTableKeys.tasksTableKey, {
        TasksTableKeys.taskIdKey: sampleTask2.taskId,
        TasksTableKeys.taskCategoryIdKey: sampleTask2.categoryId,
        TasksTableKeys.taskContentKey: sampleTask2.content,
        TasksTableKeys.taskIsRecurringKey: sampleTask2.isRecurring ? 1 : 0,
        TasksTableKeys.taskDiamondsKey: sampleTask2.diamonds,
      });
      await db.insert(TasksTableKeys.tasksTableKey, {
        TasksTableKeys.taskIdKey: sampleTask3.taskId,
        TasksTableKeys.taskCategoryIdKey: sampleTask3.categoryId,
        TasksTableKeys.taskContentKey: sampleTask3.content,
        TasksTableKeys.taskIsRecurringKey: sampleTask3.isRecurring ? 1 : 0,
        TasksTableKeys.taskDiamondsKey: sampleTask3.diamonds,
      });
      await db.insert(DayTasksTableKeys.dayTasksTableKey, {
        DayTasksTableKeys.dayTaskDayKey: '2025-11-18',
        DayTasksTableKeys.dayTaskTaskKey: sampleTask1.taskId,
        DayTasksTableKeys.dayTaskDoneKey: 0,
      });
      await db.insert(DayTasksTableKeys.dayTasksTableKey, {
        DayTasksTableKeys.dayTaskDayKey: '2025-12-19',
        DayTasksTableKeys.dayTaskTaskKey: sampleTask2.taskId,
        DayTasksTableKeys.dayTaskDoneKey: 0,
      });
      await db.insert(DayTasksTableKeys.dayTasksTableKey, {
        DayTasksTableKeys.dayTaskDayKey: '2026-01-10',
        DayTasksTableKeys.dayTaskTaskKey: sampleTask3.taskId,
        DayTasksTableKeys.dayTaskDoneKey: 0,
      });

      final tasksRows = await db.query('tasks');
      final dayTasksRows = await db.query('day_tasks');
      expect(tasksRows.length, 3);
      expect(dayTasksRows.length, 3);

      final queue = StreamQueue<TasksState>(bloc.stream);
      bloc.add(ReadTasksForMonthEvent(monthId: '2025-12'));

      final first = await queue.next;
      expect(first, TasksState(tasks: [], isLoading: true, error: null));

      final second = await queue.next;
      expect(
        second,
        TasksState(tasks: [sampleTask2], isLoading: false, error: null),
      );

      final tasksRows1 = await db.query('tasks');
      final dayTasksRows1 = await db.query('day_tasks');
      expect(tasksRows1.length, 3);
      expect(dayTasksRows1.length, 3);

      await queue.cancel();
    });
  });

  group('Adding a new task', () {
    test(
      'When adding a task for any day, the task gets added optimistically in both databases with correct day and the id gets correctly inffered',
      () async {
        final queue = StreamQueue<TasksState>(bloc.stream);
        bloc.add(
          CreateNewTaskEvent(
            dayId: sampleDayId1,
            categoryId: sampleTask1.categoryId,
            content: sampleTask1.content,
            diamonds: sampleTask1.diamonds,
            isRecurring: sampleTask1.isRecurring,
          ),
        );

        final first = await queue.next;
        expect(
          first,
          TasksState(
            tasks: [sampleTask1.copyWith(taskId: -1)],
            isLoading: true,
            error: null,
          ),
        );

        final second = await queue.next;
        expect(
          second,
          TasksState(tasks: [sampleTask1], isLoading: false, error: null),
        );

        final tasksRows1 = await db.query('tasks');
        final dayTasksRows1 = await db.query('day_tasks');
        expect(tasksRows1.length, 1);
        expect(dayTasksRows1.length, 1);
        expect(TaskModel.fromMap(tasksRows1[0]).toEntity(), sampleTask1);
        expect(dayTasksRows1[0][DayTasksTableKeys.dayTaskDayKey], sampleDayId1);
        expect(dayTasksRows1[0][DayTasksTableKeys.dayTaskDoneKey], 0);
        expect(dayTasksRows1[0][DayTasksTableKeys.dayTaskTaskKey], 1);
        expect(dayTasksRows1[0][DayTasksTableKeys.dayTaskIdKey], 1);

        await queue.cancel();
      },
    );
    test(
      'When adding 2 tasks, one after another, they both get added optimistically with correct ids',
      () async {
        final queue = StreamQueue<TasksState>(bloc.stream);
        bloc.add(
          CreateNewTaskEvent(
            dayId: sampleDayId1,
            categoryId: sampleTask1.categoryId,
            content: sampleTask1.content,
            diamonds: sampleTask1.diamonds,
            isRecurring: sampleTask1.isRecurring,
          ),
        );

        final first = await queue.next;
        expect(
          first,
          TasksState(
            tasks: [sampleTask1.copyWith(taskId: -1)],
            isLoading: true,
            error: null,
          ),
        );

        final second = await queue.next;
        expect(
          second,
          TasksState(tasks: [sampleTask1], isLoading: false, error: null),
        );

        final tasksRows1 = await db.query('tasks');
        final dayTasksRows1 = await db.query('day_tasks');
        expect(tasksRows1.length, 1);
        expect(dayTasksRows1.length, 1);
        expect(TaskModel.fromMap(tasksRows1[0]).toEntity(), sampleTask1);
        expect(dayTasksRows1[0][DayTasksTableKeys.dayTaskDayKey], sampleDayId1);
        expect(dayTasksRows1[0][DayTasksTableKeys.dayTaskDoneKey], 0);
        expect(dayTasksRows1[0][DayTasksTableKeys.dayTaskTaskKey], 1);
        expect(dayTasksRows1[0][DayTasksTableKeys.dayTaskIdKey], 1);

        bloc.add(
          CreateNewTaskEvent(
            dayId: sampleDayId1,
            categoryId: sampleTask2.categoryId,
            content: sampleTask2.content,
            diamonds: sampleTask2.diamonds,
            isRecurring: sampleTask2.isRecurring,
          ),
        );

        final third = await queue.next;
        expect(
          third,
          TasksState(
            tasks: [sampleTask1, sampleTask2.copyWith(taskId: -1)],
            isLoading: true,
            error: null,
          ),
        );

        final fourth = await queue.next;
        expect(
          fourth,
          TasksState(
            tasks: [sampleTask1, sampleTask2],
            isLoading: false,
            error: null,
          ),
        );

        final tasksRows2 = await db.query('tasks');
        final dayTasksRows2 = await db.query('day_tasks');
        expect(tasksRows2.length, 2);
        expect(dayTasksRows2.length, 2);
        expect(TaskModel.fromMap(tasksRows2[0]).toEntity(), sampleTask1);
        expect(TaskModel.fromMap(tasksRows2[1]).toEntity(), sampleTask2);
        expect(dayTasksRows1[0][DayTasksTableKeys.dayTaskDayKey], sampleDayId1);
        expect(dayTasksRows1[0][DayTasksTableKeys.dayTaskDoneKey], 0);
        expect(dayTasksRows1[0][DayTasksTableKeys.dayTaskTaskKey], 1);
        expect(dayTasksRows1[0][DayTasksTableKeys.dayTaskIdKey], 1);
        expect(dayTasksRows2[1][DayTasksTableKeys.dayTaskDayKey], sampleDayId1);
        expect(dayTasksRows2[1][DayTasksTableKeys.dayTaskDoneKey], 0);
        expect(dayTasksRows2[1][DayTasksTableKeys.dayTaskTaskKey], 2);
        expect(dayTasksRows2[1][DayTasksTableKeys.dayTaskIdKey], 2);

        await queue.cancel();
      },
    );
    test(
      'When adding 2 tasks at the same time, only the first one gets added and an error is emitted',
      () async {
        final queue = StreamQueue<TasksState>(bloc.stream);
        bloc.add(
          CreateNewTaskEvent(
            dayId: sampleDayId1,
            categoryId: sampleTask1.categoryId,
            content: sampleTask1.content,
            diamonds: sampleTask1.diamonds,
            isRecurring: sampleTask1.isRecurring,
          ),
        );
        bloc.add(
          CreateNewTaskEvent(
            dayId: sampleDayId1,
            categoryId: sampleTask2.categoryId,
            content: sampleTask2.content,
            diamonds: sampleTask2.diamonds,
            isRecurring: sampleTask2.isRecurring,
          ),
        );

        final first = await queue.next;
        expect(
          first,
          TasksState(
            tasks: [sampleTask1.copyWith(taskId: -1)],
            isLoading: true,
            error: null,
          ),
        );
        final second = await queue.next;
        expect(
          second,
          TasksState(
            tasks: [sampleTask1.copyWith(taskId: -1)],
            isLoading: true,
            error: noOperationWhileIsLoadingError,
          ),
        );
        final third = await queue.next;
        expect(
          third,
          TasksState(tasks: [sampleTask1], isLoading: false, error: null),
        );

        final tasksRows = await db.query('tasks');
        final dayTasksRows = await db.query('day_tasks');
        expect(tasksRows.length, 1);
        expect(dayTasksRows.length, 1);
        expect(TaskModel.fromMap(tasksRows[0]).toEntity(), sampleTask1);
        expect(dayTasksRows[0][DayTasksTableKeys.dayTaskDayKey], sampleDayId1);
        expect(dayTasksRows[0][DayTasksTableKeys.dayTaskDoneKey], 0);
        expect(dayTasksRows[0][DayTasksTableKeys.dayTaskTaskKey], 1);
        expect(dayTasksRows[0][DayTasksTableKeys.dayTaskIdKey], 1);

        queue.cancel();
      },
    );
  });

  group('Updating a task', () {
    test(
      'When updating a task for any day, the task gets updated optimistically',
      () async {
        await db.insert(TasksTableKeys.tasksTableKey, {
          TasksTableKeys.taskIdKey: sampleTask1.taskId,
          TasksTableKeys.taskCategoryIdKey: sampleTask1.categoryId,
          TasksTableKeys.taskContentKey: sampleTask1.content,
          TasksTableKeys.taskIsRecurringKey: sampleTask1.isRecurring ? 1 : 0,
          TasksTableKeys.taskDiamondsKey: sampleTask1.diamonds,
        });
        await db.insert(TasksTableKeys.tasksTableKey, {
          TasksTableKeys.taskIdKey: sampleTask2.taskId,
          TasksTableKeys.taskCategoryIdKey: sampleTask2.categoryId,
          TasksTableKeys.taskContentKey: sampleTask2.content,
          TasksTableKeys.taskIsRecurringKey: sampleTask2.isRecurring ? 1 : 0,
          TasksTableKeys.taskDiamondsKey: sampleTask2.diamonds,
        });
        await db.insert(DayTasksTableKeys.dayTasksTableKey, {
          DayTasksTableKeys.dayTaskDayKey: sampleDayId1,
          DayTasksTableKeys.dayTaskTaskKey: sampleTask1.taskId,
          DayTasksTableKeys.dayTaskDoneKey: 0,
        });
        await db.insert(DayTasksTableKeys.dayTasksTableKey, {
          DayTasksTableKeys.dayTaskDayKey: sampleDayId1,
          DayTasksTableKeys.dayTaskTaskKey: sampleTask2.taskId,
          DayTasksTableKeys.dayTaskDoneKey: 0,
        });

        final queue = StreamQueue<TasksState>(bloc.stream);

        bloc.add(ReadTasksForDayEvent(dayId: sampleDayId1));

        final first = await queue.next;
        expect(first, TasksState(tasks: [], isLoading: true, error: null));

        final second = await queue.next;
        expect(
          second,
          TasksState(
            tasks: [sampleTask1, sampleTask2],
            isLoading: false,
            error: null,
          ),
        );

        bloc.add(
          UpdateTaskEvent(
            taskId: sampleTask1.taskId,
            newCategoryId: sampleTask1.categoryId,
            newContent: 'updated 1',
            newDiamonds: sampleTask1.diamonds,
            newIsRecurring: sampleTask1.isRecurring,
          ),
        );

        final third = await queue.next;
        expect(
          third,
          TasksState(
            tasks: [
              sampleTask1.copyWith(content: 'updated 1'),
              sampleTask2,
            ],
            isLoading: true,
            error: null,
          ),
        );
        final fourth = await queue.next;
        expect(
          fourth,
          TasksState(
            tasks: [
              sampleTask1.copyWith(content: 'updated 1'),
              sampleTask2,
            ],
            isLoading: false,
            error: null,
          ),
        );

        final tasksRows = await db.query('tasks');
        final dayTasksRows = await db.query('day_tasks');
        expect(tasksRows.length, 2);
        expect(dayTasksRows.length, 2);
        expect(
          TaskModel.fromMap(tasksRows[0]).toEntity(),
          sampleTask1.copyWith(content: 'updated 1'),
        );
        expect(TaskModel.fromMap(tasksRows[1]).toEntity(), sampleTask2);
        expect(dayTasksRows[0][DayTasksTableKeys.dayTaskDayKey], sampleDayId1);
        expect(dayTasksRows[0][DayTasksTableKeys.dayTaskDoneKey], 0);
        expect(
          dayTasksRows[0][DayTasksTableKeys.dayTaskTaskKey],
          sampleTask1.taskId,
        );
        expect(dayTasksRows[0][DayTasksTableKeys.dayTaskIdKey], 1);
        expect(dayTasksRows[1][DayTasksTableKeys.dayTaskDayKey], sampleDayId1);
        expect(dayTasksRows[1][DayTasksTableKeys.dayTaskDoneKey], 0);
        expect(
          dayTasksRows[1][DayTasksTableKeys.dayTaskTaskKey],
          sampleTask2.taskId,
        );
        expect(dayTasksRows[1][DayTasksTableKeys.dayTaskIdKey], 2);

        await queue.cancel();
      },
    );
    test(
      'When updating a task that does not exist an error is emitted',
      () async {
        final queue = StreamQueue<TasksState>(bloc.stream);

        bloc.add(
          UpdateTaskEvent(
            taskId: sampleTask1.taskId,
            newCategoryId: sampleTask1.categoryId,
            newContent: 'updated 1',
            newDiamonds: sampleTask1.diamonds,
            newIsRecurring: sampleTask1.isRecurring,
          ),
        );

        final first = await queue.next;
        expect(
          first,
          TasksState(tasks: [], isLoading: false, error: genericError),
        );

        await queue.cancel();
      },
    );
  });

  group('Deleting a task', () {
    test(
      'When deleting a non-recurring task from any day, the task gets deleted optimistically only for that day',
      () async {
        await db.insert(TasksTableKeys.tasksTableKey, {
          TasksTableKeys.taskIdKey: sampleTask1.taskId,
          TasksTableKeys.taskCategoryIdKey: sampleTask1.categoryId,
          TasksTableKeys.taskContentKey: sampleTask1.content,
          TasksTableKeys.taskIsRecurringKey: sampleTask1.isRecurring ? 1 : 0,
          TasksTableKeys.taskDiamondsKey: sampleTask1.diamonds,
        });
        await db.insert(TasksTableKeys.tasksTableKey, {
          TasksTableKeys.taskIdKey: sampleTask2.taskId,
          TasksTableKeys.taskCategoryIdKey: sampleTask2.categoryId,
          TasksTableKeys.taskContentKey: sampleTask2.content,
          TasksTableKeys.taskIsRecurringKey: sampleTask2.isRecurring ? 1 : 0,
          TasksTableKeys.taskDiamondsKey: sampleTask2.diamonds,
        });
        await db.insert(DayTasksTableKeys.dayTasksTableKey, {
          DayTasksTableKeys.dayTaskDayKey: sampleDayId1,
          DayTasksTableKeys.dayTaskTaskKey: sampleTask1.taskId,
          DayTasksTableKeys.dayTaskDoneKey: 0,
        });
        await db.insert(DayTasksTableKeys.dayTasksTableKey, {
          DayTasksTableKeys.dayTaskDayKey: sampleDayId1,
          DayTasksTableKeys.dayTaskTaskKey: sampleTask2.taskId,
          DayTasksTableKeys.dayTaskDoneKey: 0,
        });

        final queue = StreamQueue<TasksState>(bloc.stream);

        bloc.add(ReadTasksForDayEvent(dayId: sampleDayId1));

        final first = await queue.next;
        expect(first, TasksState(tasks: [], isLoading: true, error: null));

        final second = await queue.next;
        expect(
          second,
          TasksState(
            tasks: [sampleTask1, sampleTask2],
            isLoading: false,
            error: null,
          ),
        );

        bloc.add(
          DeleteTaskEvent(dayId: sampleDayId1, taskId: sampleTask1.taskId),
        );

        final third = await queue.next;
        expect(
          third,
          TasksState(tasks: [sampleTask2], isLoading: true, error: null),
        );
        final fourth = await queue.next;
        expect(
          fourth,
          TasksState(tasks: [sampleTask2], isLoading: false, error: null),
        );

        final tasksRows = await db.query('tasks');
        final dayTasksRows = await db.query('day_tasks');
        expect(tasksRows.length, 2);
        expect(dayTasksRows.length, 1);
        expect(TaskModel.fromMap(tasksRows[0]).toEntity(), sampleTask1);
        expect(TaskModel.fromMap(tasksRows[1]).toEntity(), sampleTask2);
        expect(dayTasksRows[0][DayTasksTableKeys.dayTaskDayKey], sampleDayId1);
        expect(dayTasksRows[0][DayTasksTableKeys.dayTaskDoneKey], 0);
        expect(
          dayTasksRows[0][DayTasksTableKeys.dayTaskTaskKey],
          sampleTask2.taskId,
        );
        expect(dayTasksRows[0][DayTasksTableKeys.dayTaskIdKey], 2);

        await queue.cancel();
      },
    );
    test(
      'When deleting a recurring task from any day, the task gets deleted optimistically only for that day and becomes non-recurring',
      () async {
        await db.insert(TasksTableKeys.tasksTableKey, {
          TasksTableKeys.taskIdKey: sampleTask2.taskId,
          TasksTableKeys.taskCategoryIdKey: sampleTask2.categoryId,
          TasksTableKeys.taskContentKey: sampleTask2.content,
          TasksTableKeys.taskIsRecurringKey: sampleTask2.isRecurring ? 1 : 0,
          TasksTableKeys.taskDiamondsKey: sampleTask2.diamonds,
        });
        await db.insert(TasksTableKeys.tasksTableKey, {
          TasksTableKeys.taskIdKey: sampleTask3.taskId,
          TasksTableKeys.taskCategoryIdKey: sampleTask3.categoryId,
          TasksTableKeys.taskContentKey: sampleTask3.content,
          TasksTableKeys.taskIsRecurringKey: sampleTask3.isRecurring ? 1 : 0,
          TasksTableKeys.taskDiamondsKey: sampleTask3.diamonds,
        });
        await db.insert(DayTasksTableKeys.dayTasksTableKey, {
          DayTasksTableKeys.dayTaskDayKey: sampleDayId1,
          DayTasksTableKeys.dayTaskTaskKey: sampleTask2.taskId,
          DayTasksTableKeys.dayTaskDoneKey: 0,
        });
        await db.insert(DayTasksTableKeys.dayTasksTableKey, {
          DayTasksTableKeys.dayTaskDayKey: sampleDayId1,
          DayTasksTableKeys.dayTaskTaskKey: sampleTask3.taskId,
          DayTasksTableKeys.dayTaskDoneKey: 0,
        });

        final queue = StreamQueue<TasksState>(bloc.stream);

        bloc.add(ReadTasksForDayEvent(dayId: sampleDayId1));

        final first = await queue.next;
        expect(first, TasksState(tasks: [], isLoading: true, error: null));

        final second = await queue.next;
        expect(
          second,
          TasksState(
            tasks: [sampleTask2, sampleTask3],
            isLoading: false,
            error: null,
          ),
        );

        expect(sampleTask3.isRecurring, true);

        bloc.add(
          DeleteTaskEvent(dayId: sampleDayId1, taskId: sampleTask3.taskId),
        );

        final third = await queue.next;
        expect(
          third,
          TasksState(tasks: [sampleTask2], isLoading: true, error: null),
        );
        final fourth = await queue.next;
        expect(
          fourth,
          TasksState(tasks: [sampleTask2], isLoading: false, error: null),
        );

        final tasksRows = await db.query('tasks');
        final dayTasksRows = await db.query('day_tasks');
        expect(tasksRows.length, 2);
        expect(dayTasksRows.length, 1);
        expect(TaskModel.fromMap(tasksRows[0]).toEntity(), sampleTask2);
        expect(
          TaskModel.fromMap(tasksRows[1]).toEntity(),
          sampleTask3.copyWith(isRecurring: false),
        );
        expect(dayTasksRows[0][DayTasksTableKeys.dayTaskDayKey], sampleDayId1);
        expect(dayTasksRows[0][DayTasksTableKeys.dayTaskDoneKey], 0);
        expect(
          dayTasksRows[0][DayTasksTableKeys.dayTaskTaskKey],
          sampleTask2.taskId,
        );
        expect(dayTasksRows[0][DayTasksTableKeys.dayTaskIdKey], 1);

        await queue.cancel();
      },
    );
    test(
      'When deleting a task from a month, the task gets deleted completely',
      () async {
        await db.insert(TasksTableKeys.tasksTableKey, {
          TasksTableKeys.taskIdKey: sampleTask2.taskId,
          TasksTableKeys.taskCategoryIdKey: sampleTask2.categoryId,
          TasksTableKeys.taskContentKey: sampleTask2.content,
          TasksTableKeys.taskIsRecurringKey: sampleTask2.isRecurring ? 1 : 0,
          TasksTableKeys.taskDiamondsKey: sampleTask2.diamonds,
        });
        await db.insert(TasksTableKeys.tasksTableKey, {
          TasksTableKeys.taskIdKey: sampleTask3.taskId,
          TasksTableKeys.taskCategoryIdKey: sampleTask3.categoryId,
          TasksTableKeys.taskContentKey: sampleTask3.content,
          TasksTableKeys.taskIsRecurringKey: sampleTask3.isRecurring ? 1 : 0,
          TasksTableKeys.taskDiamondsKey: sampleTask3.diamonds,
        });
        await db.insert(DayTasksTableKeys.dayTasksTableKey, {
          DayTasksTableKeys.dayTaskDayKey: sampleDayId1,
          DayTasksTableKeys.dayTaskTaskKey: sampleTask2.taskId,
          DayTasksTableKeys.dayTaskDoneKey: 0,
        });
        await db.insert(DayTasksTableKeys.dayTasksTableKey, {
          DayTasksTableKeys.dayTaskDayKey: sampleDayId2,
          DayTasksTableKeys.dayTaskTaskKey: sampleTask3.taskId,
          DayTasksTableKeys.dayTaskDoneKey: 0,
        });

        final queue = StreamQueue<TasksState>(bloc.stream);

        bloc.add(ReadTasksForMonthEvent(monthId: sampleMonthId1));

        final first = await queue.next;
        expect(first, TasksState(tasks: [], isLoading: true, error: null));

        final second = await queue.next;
        expect(
          second,
          TasksState(
            tasks: [sampleTask2, sampleTask3],
            isLoading: false,
            error: null,
          ),
        );

        bloc.add(DeleteTaskEvent(dayId: null, taskId: sampleTask3.taskId));

        final third = await queue.next;
        expect(
          third,
          TasksState(tasks: [sampleTask2], isLoading: true, error: null),
        );
        final fourth = await queue.next;
        expect(
          fourth,
          TasksState(tasks: [sampleTask2], isLoading: false, error: null),
        );

        final tasksRows = await db.query('tasks');
        final dayTasksRows = await db.query('day_tasks');
        expect(tasksRows.length, 1);
        expect(dayTasksRows.length, 1);
        expect(TaskModel.fromMap(tasksRows[0]).toEntity(), sampleTask2);
        expect(dayTasksRows[0][DayTasksTableKeys.dayTaskDayKey], sampleDayId1);
        expect(dayTasksRows[0][DayTasksTableKeys.dayTaskDoneKey], 0);
        expect(
          dayTasksRows[0][DayTasksTableKeys.dayTaskTaskKey],
          sampleTask2.taskId,
        );
        expect(dayTasksRows[0][DayTasksTableKeys.dayTaskIdKey], 1);

        await queue.cancel();
      },
    );
    test(
      'When deleting a task that does not exist, an error is emitted',
      () async {
        final queue = StreamQueue<TasksState>(bloc.stream);

        bloc.add(
          DeleteTaskEvent(dayId: sampleDayId1, taskId: sampleTask3.taskId),
        );

        final first = await queue.next;
        expect(
          first,
          TasksState(tasks: [], isLoading: false, error: genericError),
        );

        final tasksRows = await db.query('tasks');
        final dayTasksRows = await db.query('day_tasks');
        expect(tasksRows.length, 0);
        expect(dayTasksRows.length, 0);

        await queue.cancel();
      },
    );
  });

  group('Setting a task', () {
    test(
      'When setting a task for any day, the task gets set optimistically',
      () async {
        await db.insert(TasksTableKeys.tasksTableKey, {
          TasksTableKeys.taskIdKey: sampleTask1.taskId,
          TasksTableKeys.taskCategoryIdKey: sampleTask1.categoryId,
          TasksTableKeys.taskContentKey: sampleTask1.content,
          TasksTableKeys.taskIsRecurringKey: sampleTask1.isRecurring ? 1 : 0,
          TasksTableKeys.taskDiamondsKey: sampleTask1.diamonds,
        });
        await db.insert(TasksTableKeys.tasksTableKey, {
          TasksTableKeys.taskIdKey: sampleTask2.taskId,
          TasksTableKeys.taskCategoryIdKey: sampleTask2.categoryId,
          TasksTableKeys.taskContentKey: sampleTask2.content,
          TasksTableKeys.taskIsRecurringKey: sampleTask2.isRecurring ? 1 : 0,
          TasksTableKeys.taskDiamondsKey: sampleTask2.diamonds,
        });
        await db.insert(DayTasksTableKeys.dayTasksTableKey, {
          DayTasksTableKeys.dayTaskDayKey: sampleDayId1,
          DayTasksTableKeys.dayTaskTaskKey: sampleTask1.taskId,
          DayTasksTableKeys.dayTaskDoneKey: 0,
        });
        await db.insert(DayTasksTableKeys.dayTasksTableKey, {
          DayTasksTableKeys.dayTaskDayKey: sampleDayId1,
          DayTasksTableKeys.dayTaskTaskKey: sampleTask2.taskId,
          DayTasksTableKeys.dayTaskDoneKey: 0,
        });

        final queue = StreamQueue<TasksState>(bloc.stream);

        bloc.add(ReadTasksForDayEvent(dayId: sampleDayId1));

        final first = await queue.next;
        expect(first, TasksState(tasks: [], isLoading: true, error: null));

        final second = await queue.next;
        expect(
          second,
          TasksState(
            tasks: [sampleTask1, sampleTask2],
            isLoading: false,
            error: null,
          ),
        );

        bloc.add(
          SetTaskEvent(
            dayId: sampleDayId1,
            taskId: sampleTask1.taskId,
            completed: true,
          ),
        );

        final third = await queue.next;
        expect(
          third,
          TasksState(
            tasks: [sampleTask1.copyWith(isDone: true), sampleTask2],
            isLoading: true,
            error: null,
          ),
        );
        final fourth = await queue.next;
        expect(
          fourth,
          TasksState(
            tasks: [sampleTask1.copyWith(isDone: true), sampleTask2],
            isLoading: false,
            error: null,
          ),
        );

        final tasksRows = await db.query('tasks');
        final dayTasksRows = await db.query('day_tasks');
        expect(tasksRows.length, 2);
        expect(dayTasksRows.length, 2);
        expect(TaskModel.fromMap(tasksRows[0]).toEntity(), sampleTask1);
        expect(TaskModel.fromMap(tasksRows[1]).toEntity(), sampleTask2);
        expect(dayTasksRows[0][DayTasksTableKeys.dayTaskDayKey], sampleDayId1);
        expect(dayTasksRows[0][DayTasksTableKeys.dayTaskDoneKey], 1);
        expect(
          dayTasksRows[0][DayTasksTableKeys.dayTaskTaskKey],
          sampleTask1.taskId,
        );
        expect(dayTasksRows[0][DayTasksTableKeys.dayTaskIdKey], 1);

        expect(dayTasksRows[1][DayTasksTableKeys.dayTaskDayKey], sampleDayId1);
        expect(dayTasksRows[1][DayTasksTableKeys.dayTaskDoneKey], 0);
        expect(
          dayTasksRows[1][DayTasksTableKeys.dayTaskTaskKey],
          sampleTask2.taskId,
        );
        expect(dayTasksRows[1][DayTasksTableKeys.dayTaskIdKey], 2);

        await queue.cancel();
      },
    );
    test(
      'When setting a task that does not exist, an error is emitted',
      () async {
        final queue = StreamQueue<TasksState>(bloc.stream);
        bloc.add(
          SetTaskEvent(
            dayId: sampleDayId1,
            taskId: sampleTask1.taskId,
            completed: true,
          ),
        );
        expect(
          await queue.next,
          TasksState(tasks: [], isLoading: false, error: genericError),
        );
        final tasksRows = await db.query('tasks');
        final dayTasksRows = await db.query('day_tasks');
        expect(tasksRows.length, 0);
        expect(dayTasksRows.length, 0);

        await queue.cancel();
      },
    );
  });

  test(
    '''Tasks feature flow 1 - 
    the user initializez a day - check if empty
    adds 4 tasks, from which 3 are recurring - check if correctly set in the db
    sets 2 recurring tasks and one non-recurring - check if correctly set in the db
    initializes another day - check if it has the recurring tasks
    adds one more non-recurring task - check if correctly added in the db
    sets one recurring task - check if correctly set in the db
    updates another recurring task - check if correctly set in the db
    deletes the other recurring task - check if correctly set in the db
    deletes the non-recurring task from today - check if correctly set in the db
    reads tasks from previous day - check if they are all there, with the one updated correctly
    initializes another day - check if it has only the 2 recurring tasks remaining, with the updated one
    gets all tasks for current month - check if they are all there, including the deleted non-recurring
    deletes a recurring task and a non-recurring task from first day - check if correctly deleted
    reads tasks from first day - check if the recurring and non-recurring are gone
    initializes another day - check if correctly initialized
  ''',
    () async {
      final TaskEntity t1 = TaskEntity(
        taskId: 1,
        categoryId: 1,
        content: 'test 1',
        isRecurring: true,
        diamonds: 11,
        isDone: false,
      );
      final TaskEntity t2 = TaskEntity(
        taskId: 2,
        categoryId: 2,
        content: 'test 2',
        isRecurring: true,
        diamonds: 22,
        isDone: false,
      );
      final TaskEntity t3 = TaskEntity(
        taskId: 3,
        categoryId: 3,
        content: 'test 3',
        isRecurring: true,
        diamonds: 33,
        isDone: false,
      );
      final TaskEntity t4 = TaskEntity(
        taskId: 4,
        categoryId: 4,
        content: 'test 4',
        isRecurring: false,
        diamonds: 44,
        isDone: false,
      );
      final TaskEntity t5 = TaskEntity(
        taskId: 5,
        categoryId: 5,
        content: 'test 5',
        isRecurring: false,
        diamonds: 55,
        isDone: false,
      );
      var tasksRows = await db.query('tasks');
      var dayTasksRows = await db.query('day_tasks');
      expect(tasksRows.length, 0);
      expect(dayTasksRows.length, 0);

      final queue = StreamQueue<TasksState>(bloc.stream);

      // the user initializez a day - check if empty
      bloc.add(InitializeTasksForDayEvent(dayId: '2025-08-22'));
      expect(
        await queue.next,
        TasksState(tasks: [], isLoading: true, error: null),
      );
      expect(
        await queue.next,
        TasksState(tasks: [], isLoading: false, error: null),
      );

      // adds 4 tasks, from which 3 are recurring - check if correctly set in the db
      bloc.add(
        CreateNewTaskEvent(
          dayId: '2025-08-22',
          categoryId: t1.categoryId,
          content: t1.content,
          isRecurring: t1.isRecurring,
          diamonds: t1.diamonds,
        ),
      );
      expect(
        await queue.next,
        TasksState(
          tasks: [t1.copyWith(taskId: -1)],
          isLoading: true,
          error: null,
        ),
      );
      expect(
        await queue.next,
        TasksState(tasks: [t1], isLoading: false, error: null),
      );
      bloc.add(
        CreateNewTaskEvent(
          dayId: '2025-08-22',
          categoryId: t2.categoryId,
          content: t2.content,
          isRecurring: t2.isRecurring,
          diamonds: t2.diamonds,
        ),
      );
      expect(
        await queue.next,
        TasksState(
          tasks: [t1, t2.copyWith(taskId: -1)],
          isLoading: true,
          error: null,
        ),
      );
      expect(
        await queue.next,
        TasksState(tasks: [t1, t2], isLoading: false, error: null),
      );
      bloc.add(
        CreateNewTaskEvent(
          dayId: '2025-08-22',
          categoryId: t3.categoryId,
          content: t3.content,
          isRecurring: t3.isRecurring,
          diamonds: t3.diamonds,
        ),
      );
      expect(
        await queue.next,
        TasksState(
          tasks: [t1, t2, t3.copyWith(taskId: -1)],
          isLoading: true,
          error: null,
        ),
      );
      expect(
        await queue.next,
        TasksState(tasks: [t1, t2, t3], isLoading: false, error: null),
      );
      bloc.add(
        CreateNewTaskEvent(
          dayId: '2025-08-22',
          categoryId: t4.categoryId,
          content: t4.content,
          isRecurring: t4.isRecurring,
          diamonds: t4.diamonds,
        ),
      );
      expect(
        await queue.next,
        TasksState(
          tasks: [t1, t2, t3, t4.copyWith(taskId: -1)],
          isLoading: true,
          error: null,
        ),
      );
      expect(
        await queue.next,
        TasksState(tasks: [t1, t2, t3, t4], isLoading: false, error: null),
      );

      tasksRows = await db.query('tasks');
      dayTasksRows = await db.query('day_tasks');
      expect(tasksRows.length, 4);
      expect(TaskModel.fromMap(tasksRows[0]).toEntity(), t1);
      expect(t1.isRecurring, true);
      expect(t2.isRecurring, true);
      expect(t3.isRecurring, true);
      expect(t4.isRecurring, false);
      expect(TaskModel.fromMap(tasksRows[1]).toEntity(), t2);
      expect(TaskModel.fromMap(tasksRows[2]).toEntity(), t3);
      expect(TaskModel.fromMap(tasksRows[3]).toEntity(), t4);
      expect(dayTasksRows.length, 4);
      expect(dayTasksRows[0][DayTasksTableKeys.dayTaskDayKey], '2025-08-22');
      expect(dayTasksRows[0][DayTasksTableKeys.dayTaskTaskKey], t1.taskId);
      expect(dayTasksRows[1][DayTasksTableKeys.dayTaskDayKey], '2025-08-22');
      expect(dayTasksRows[1][DayTasksTableKeys.dayTaskTaskKey], t2.taskId);
      expect(dayTasksRows[2][DayTasksTableKeys.dayTaskDayKey], '2025-08-22');
      expect(dayTasksRows[2][DayTasksTableKeys.dayTaskTaskKey], t3.taskId);
      expect(dayTasksRows[3][DayTasksTableKeys.dayTaskDayKey], '2025-08-22');
      expect(dayTasksRows[3][DayTasksTableKeys.dayTaskTaskKey], t4.taskId);

      // sets 2 recurring tasks and one non-recurring - check if correctly set in the db
      bloc.add(
        SetTaskEvent(dayId: '2025-08-22', taskId: t1.taskId, completed: true),
      );
      expect(
        await queue.next,
        TasksState(
          tasks: [t1.copyWith(isDone: true), t2, t3, t4],
          isLoading: true,
          error: null,
        ),
      );
      expect(
        await queue.next,
        TasksState(
          tasks: [t1.copyWith(isDone: true), t2, t3, t4],
          isLoading: false,
          error: null,
        ),
      );
      bloc.add(
        SetTaskEvent(dayId: '2025-08-22', taskId: t2.taskId, completed: true),
      );
      expect(
        await queue.next,
        TasksState(
          tasks: [t1.copyWith(isDone: true), t2.copyWith(isDone: true), t3, t4],
          isLoading: true,
          error: null,
        ),
      );
      expect(
        await queue.next,
        TasksState(
          tasks: [t1.copyWith(isDone: true), t2.copyWith(isDone: true), t3, t4],
          isLoading: false,
          error: null,
        ),
      );
      bloc.add(
        SetTaskEvent(dayId: '2025-08-22', taskId: t2.taskId, completed: true),
      );
      expect(
        await queue.next,
        TasksState(
          tasks: [t1.copyWith(isDone: true), t2.copyWith(isDone: true), t3, t4],
          isLoading: true,
          error: null,
        ),
      );
      expect(
        await queue.next,
        TasksState(
          tasks: [t1.copyWith(isDone: true), t2.copyWith(isDone: true), t3, t4],
          isLoading: false,
          error: null,
        ),
      );
      bloc.add(
        SetTaskEvent(dayId: '2025-08-22', taskId: t4.taskId, completed: true),
      );
      expect(
        await queue.next,
        TasksState(
          tasks: [
            t1.copyWith(isDone: true),
            t2.copyWith(isDone: true),
            t3,
            t4.copyWith(isDone: true),
          ],
          isLoading: true,
          error: null,
        ),
      );
      expect(
        await queue.next,
        TasksState(
          tasks: [
            t1.copyWith(isDone: true),
            t2.copyWith(isDone: true),
            t3,
            t4.copyWith(isDone: true),
          ],
          isLoading: false,
          error: null,
        ),
      );
      tasksRows = await db.query('tasks');
      dayTasksRows = await db.query('day_tasks');
      expect(tasksRows.length, 4);
      expect(TaskModel.fromMap(tasksRows[0]).toEntity(), t1);
      expect(TaskModel.fromMap(tasksRows[1]).toEntity(), t2);
      expect(TaskModel.fromMap(tasksRows[2]).toEntity(), t3);
      expect(TaskModel.fromMap(tasksRows[3]).toEntity(), t4);
      expect(dayTasksRows.length, 4);
      expect(dayTasksRows[0][DayTasksTableKeys.dayTaskDayKey], '2025-08-22');
      expect(dayTasksRows[0][DayTasksTableKeys.dayTaskTaskKey], t1.taskId);
      expect(dayTasksRows[0][DayTasksTableKeys.dayTaskDoneKey], 1);
      expect(dayTasksRows[1][DayTasksTableKeys.dayTaskDayKey], '2025-08-22');
      expect(dayTasksRows[1][DayTasksTableKeys.dayTaskTaskKey], t2.taskId);
      expect(dayTasksRows[1][DayTasksTableKeys.dayTaskDoneKey], 1);
      expect(dayTasksRows[2][DayTasksTableKeys.dayTaskDayKey], '2025-08-22');
      expect(dayTasksRows[2][DayTasksTableKeys.dayTaskTaskKey], t3.taskId);
      expect(dayTasksRows[2][DayTasksTableKeys.dayTaskDoneKey], 0);
      expect(dayTasksRows[3][DayTasksTableKeys.dayTaskDayKey], '2025-08-22');
      expect(dayTasksRows[3][DayTasksTableKeys.dayTaskTaskKey], t4.taskId);
      expect(dayTasksRows[3][DayTasksTableKeys.dayTaskDoneKey], 1);

      // initializes another day - check if it has the recurring tasks
      bloc.add(InitializeTasksForDayEvent(dayId: '2025-08-23'));
      expect(
        await queue.next,
        TasksState(tasks: [], isLoading: true, error: null),
      );
      expect(
        await queue.next,
        TasksState(tasks: [t1, t2, t3], isLoading: false, error: null),
      );
      tasksRows = await db.query('tasks');
      dayTasksRows = await db.query('day_tasks');
      expect(tasksRows.length, 4);
      expect(TaskModel.fromMap(tasksRows[0]).toEntity(), t1);
      expect(TaskModel.fromMap(tasksRows[1]).toEntity(), t2);
      expect(TaskModel.fromMap(tasksRows[2]).toEntity(), t3);
      expect(TaskModel.fromMap(tasksRows[3]).toEntity(), t4);
      expect(dayTasksRows.length, 7);
      expect(dayTasksRows[0][DayTasksTableKeys.dayTaskDayKey], '2025-08-22');
      expect(dayTasksRows[0][DayTasksTableKeys.dayTaskTaskKey], t1.taskId);
      expect(dayTasksRows[0][DayTasksTableKeys.dayTaskDoneKey], 1);
      expect(dayTasksRows[1][DayTasksTableKeys.dayTaskDayKey], '2025-08-22');
      expect(dayTasksRows[1][DayTasksTableKeys.dayTaskTaskKey], t2.taskId);
      expect(dayTasksRows[1][DayTasksTableKeys.dayTaskDoneKey], 1);
      expect(dayTasksRows[2][DayTasksTableKeys.dayTaskDayKey], '2025-08-22');
      expect(dayTasksRows[2][DayTasksTableKeys.dayTaskTaskKey], t3.taskId);
      expect(dayTasksRows[2][DayTasksTableKeys.dayTaskDoneKey], 0);
      expect(dayTasksRows[3][DayTasksTableKeys.dayTaskDayKey], '2025-08-22');
      expect(dayTasksRows[3][DayTasksTableKeys.dayTaskTaskKey], t4.taskId);
      expect(dayTasksRows[3][DayTasksTableKeys.dayTaskDoneKey], 1);
      expect(dayTasksRows[4][DayTasksTableKeys.dayTaskDayKey], '2025-08-23');
      expect(dayTasksRows[4][DayTasksTableKeys.dayTaskTaskKey], t1.taskId);
      expect(dayTasksRows[4][DayTasksTableKeys.dayTaskDoneKey], 0);
      expect(dayTasksRows[5][DayTasksTableKeys.dayTaskDayKey], '2025-08-23');
      expect(dayTasksRows[5][DayTasksTableKeys.dayTaskTaskKey], t2.taskId);
      expect(dayTasksRows[5][DayTasksTableKeys.dayTaskDoneKey], 0);
      expect(dayTasksRows[6][DayTasksTableKeys.dayTaskDayKey], '2025-08-23');
      expect(dayTasksRows[6][DayTasksTableKeys.dayTaskTaskKey], t3.taskId);
      expect(dayTasksRows[6][DayTasksTableKeys.dayTaskDoneKey], 0);

      // adds one more non-recurring task - check if correctly added in the db
      bloc.add(
        CreateNewTaskEvent(
          dayId: '2025-08-23',
          categoryId: t5.categoryId,
          content: t5.content,
          isRecurring: t5.isRecurring,
          diamonds: t5.diamonds,
        ),
      );
      expect(
        await queue.next,
        TasksState(
          tasks: [t1, t2, t3, t5.copyWith(taskId: -1)],
          isLoading: true,
          error: null,
        ),
      );
      expect(
        await queue.next,
        TasksState(tasks: [t1, t2, t3, t5], isLoading: false, error: null),
      );
      tasksRows = await db.query('tasks');
      dayTasksRows = await db.query('day_tasks');
      expect(tasksRows.length, 5);
      expect(TaskModel.fromMap(tasksRows[0]).toEntity(), t1);
      expect(TaskModel.fromMap(tasksRows[1]).toEntity(), t2);
      expect(TaskModel.fromMap(tasksRows[2]).toEntity(), t3);
      expect(TaskModel.fromMap(tasksRows[3]).toEntity(), t4);
      expect(TaskModel.fromMap(tasksRows[4]).toEntity(), t5);
      expect(t5.isRecurring, false);
      expect(dayTasksRows.length, 8);
      expect(dayTasksRows[0][DayTasksTableKeys.dayTaskDayKey], '2025-08-22');
      expect(dayTasksRows[0][DayTasksTableKeys.dayTaskTaskKey], t1.taskId);
      expect(dayTasksRows[0][DayTasksTableKeys.dayTaskDoneKey], 1);
      expect(dayTasksRows[1][DayTasksTableKeys.dayTaskDayKey], '2025-08-22');
      expect(dayTasksRows[1][DayTasksTableKeys.dayTaskTaskKey], t2.taskId);
      expect(dayTasksRows[1][DayTasksTableKeys.dayTaskDoneKey], 1);
      expect(dayTasksRows[2][DayTasksTableKeys.dayTaskDayKey], '2025-08-22');
      expect(dayTasksRows[2][DayTasksTableKeys.dayTaskTaskKey], t3.taskId);
      expect(dayTasksRows[2][DayTasksTableKeys.dayTaskDoneKey], 0);
      expect(dayTasksRows[3][DayTasksTableKeys.dayTaskDayKey], '2025-08-22');
      expect(dayTasksRows[3][DayTasksTableKeys.dayTaskTaskKey], t4.taskId);
      expect(dayTasksRows[3][DayTasksTableKeys.dayTaskDoneKey], 1);
      expect(dayTasksRows[4][DayTasksTableKeys.dayTaskDayKey], '2025-08-23');
      expect(dayTasksRows[4][DayTasksTableKeys.dayTaskTaskKey], t1.taskId);
      expect(dayTasksRows[4][DayTasksTableKeys.dayTaskDoneKey], 0);
      expect(dayTasksRows[5][DayTasksTableKeys.dayTaskDayKey], '2025-08-23');
      expect(dayTasksRows[5][DayTasksTableKeys.dayTaskTaskKey], t2.taskId);
      expect(dayTasksRows[5][DayTasksTableKeys.dayTaskDoneKey], 0);
      expect(dayTasksRows[6][DayTasksTableKeys.dayTaskDayKey], '2025-08-23');
      expect(dayTasksRows[6][DayTasksTableKeys.dayTaskTaskKey], t3.taskId);
      expect(dayTasksRows[6][DayTasksTableKeys.dayTaskDoneKey], 0);
      expect(dayTasksRows[7][DayTasksTableKeys.dayTaskDayKey], '2025-08-23');
      expect(dayTasksRows[7][DayTasksTableKeys.dayTaskTaskKey], t5.taskId);
      expect(dayTasksRows[7][DayTasksTableKeys.dayTaskDoneKey], 0);

      // sets one recurring task - check if correctly set in the db
      bloc.add(
        SetTaskEvent(dayId: '2025-08-23', taskId: t1.taskId, completed: true),
      );
      expect(
        await queue.next,
        TasksState(
          tasks: [t1.copyWith(isDone: true), t2, t3, t5],
          isLoading: true,
          error: null,
        ),
      );
      expect(
        await queue.next,
        TasksState(
          tasks: [t1.copyWith(isDone: true), t2, t3, t5],
          isLoading: false,
          error: null,
        ),
      );
      tasksRows = await db.query('tasks');
      dayTasksRows = await db.query('day_tasks');
      expect(tasksRows.length, 5);
      expect(TaskModel.fromMap(tasksRows[0]).toEntity(), t1);
      expect(TaskModel.fromMap(tasksRows[1]).toEntity(), t2);
      expect(TaskModel.fromMap(tasksRows[2]).toEntity(), t3);
      expect(TaskModel.fromMap(tasksRows[3]).toEntity(), t4);
      expect(TaskModel.fromMap(tasksRows[4]).toEntity(), t5);
      expect(t5.isRecurring, false);
      expect(dayTasksRows.length, 8);
      expect(dayTasksRows[0][DayTasksTableKeys.dayTaskDayKey], '2025-08-22');
      expect(dayTasksRows[0][DayTasksTableKeys.dayTaskTaskKey], t1.taskId);
      expect(dayTasksRows[0][DayTasksTableKeys.dayTaskDoneKey], 1);
      expect(dayTasksRows[1][DayTasksTableKeys.dayTaskDayKey], '2025-08-22');
      expect(dayTasksRows[1][DayTasksTableKeys.dayTaskTaskKey], t2.taskId);
      expect(dayTasksRows[1][DayTasksTableKeys.dayTaskDoneKey], 1);
      expect(dayTasksRows[2][DayTasksTableKeys.dayTaskDayKey], '2025-08-22');
      expect(dayTasksRows[2][DayTasksTableKeys.dayTaskTaskKey], t3.taskId);
      expect(dayTasksRows[2][DayTasksTableKeys.dayTaskDoneKey], 0);
      expect(dayTasksRows[3][DayTasksTableKeys.dayTaskDayKey], '2025-08-22');
      expect(dayTasksRows[3][DayTasksTableKeys.dayTaskTaskKey], t4.taskId);
      expect(dayTasksRows[3][DayTasksTableKeys.dayTaskDoneKey], 1);
      expect(dayTasksRows[4][DayTasksTableKeys.dayTaskDayKey], '2025-08-23');
      expect(dayTasksRows[4][DayTasksTableKeys.dayTaskTaskKey], t1.taskId);
      expect(dayTasksRows[4][DayTasksTableKeys.dayTaskDoneKey], 1);
      expect(dayTasksRows[5][DayTasksTableKeys.dayTaskDayKey], '2025-08-23');
      expect(dayTasksRows[5][DayTasksTableKeys.dayTaskTaskKey], t2.taskId);
      expect(dayTasksRows[5][DayTasksTableKeys.dayTaskDoneKey], 0);
      expect(dayTasksRows[6][DayTasksTableKeys.dayTaskDayKey], '2025-08-23');
      expect(dayTasksRows[6][DayTasksTableKeys.dayTaskTaskKey], t3.taskId);
      expect(dayTasksRows[6][DayTasksTableKeys.dayTaskDoneKey], 0);
      expect(dayTasksRows[7][DayTasksTableKeys.dayTaskDayKey], '2025-08-23');
      expect(dayTasksRows[7][DayTasksTableKeys.dayTaskTaskKey], t5.taskId);
      expect(dayTasksRows[7][DayTasksTableKeys.dayTaskDoneKey], 0);

      // updates another recurring task - check if correctly set in the db
      bloc.add(
        UpdateTaskEvent(
          taskId: t2.taskId,
          newCategoryId: t2.categoryId,
          newContent: 'updated 2',
          newIsRecurring: t2.isRecurring,
          newDiamonds: t2.diamonds,
        ),
      );
      expect(
        await queue.next,
        TasksState(
          tasks: [
            t1.copyWith(isDone: true),
            t2.copyWith(content: 'updated 2'),
            t3,
            t5,
          ],
          isLoading: true,
          error: null,
        ),
      );
      expect(
        await queue.next,
        TasksState(
          tasks: [
            t1.copyWith(isDone: true),
            t2.copyWith(content: 'updated 2'),
            t3,
            t5,
          ],
          isLoading: false,
          error: null,
        ),
      );
      tasksRows = await db.query('tasks');
      dayTasksRows = await db.query('day_tasks');
      expect(tasksRows.length, 5);
      expect(TaskModel.fromMap(tasksRows[0]).toEntity(), t1);
      expect(
        TaskModel.fromMap(tasksRows[1]).toEntity(),
        t2.copyWith(content: 'updated 2'),
      );
      expect(TaskModel.fromMap(tasksRows[2]).toEntity(), t3);
      expect(TaskModel.fromMap(tasksRows[3]).toEntity(), t4);
      expect(TaskModel.fromMap(tasksRows[4]).toEntity(), t5);

      // deletes the other recurring task - check if correctly set in the db
      bloc.add(DeleteTaskEvent(dayId: '2025-08-23', taskId: t3.taskId));
      expect(
        await queue.next,
        TasksState(
          tasks: [
            t1.copyWith(isDone: true),
            t2.copyWith(content: 'updated 2'),
            t5,
          ],
          isLoading: true,
          error: null,
        ),
      );
      expect(
        await queue.next,
        TasksState(
          tasks: [
            t1.copyWith(isDone: true),
            t2.copyWith(content: 'updated 2'),
            t5,
          ],
          isLoading: false,
          error: null,
        ),
      );
      tasksRows = await db.query('tasks');
      dayTasksRows = await db.query('day_tasks');
      expect(tasksRows.length, 5);
      expect(TaskModel.fromMap(tasksRows[0]).toEntity(), t1);
      expect(
        TaskModel.fromMap(tasksRows[1]).toEntity(),
        t2.copyWith(content: 'updated 2'),
      );
      expect(
        TaskModel.fromMap(tasksRows[2]).toEntity(),
        t3.copyWith(isRecurring: false),
      );
      expect(TaskModel.fromMap(tasksRows[3]).toEntity(), t4);
      expect(TaskModel.fromMap(tasksRows[4]).toEntity(), t5);
      expect(dayTasksRows.length, 7);
      expect(dayTasksRows[0][DayTasksTableKeys.dayTaskDayKey], '2025-08-22');
      expect(dayTasksRows[0][DayTasksTableKeys.dayTaskTaskKey], t1.taskId);
      expect(dayTasksRows[0][DayTasksTableKeys.dayTaskDoneKey], 1);
      expect(dayTasksRows[1][DayTasksTableKeys.dayTaskDayKey], '2025-08-22');
      expect(dayTasksRows[1][DayTasksTableKeys.dayTaskTaskKey], t2.taskId);
      expect(dayTasksRows[1][DayTasksTableKeys.dayTaskDoneKey], 1);
      expect(dayTasksRows[2][DayTasksTableKeys.dayTaskDayKey], '2025-08-22');
      expect(dayTasksRows[2][DayTasksTableKeys.dayTaskTaskKey], t3.taskId);
      expect(dayTasksRows[2][DayTasksTableKeys.dayTaskDoneKey], 0);
      expect(dayTasksRows[3][DayTasksTableKeys.dayTaskDayKey], '2025-08-22');
      expect(dayTasksRows[3][DayTasksTableKeys.dayTaskTaskKey], t4.taskId);
      expect(dayTasksRows[3][DayTasksTableKeys.dayTaskDoneKey], 1);
      expect(dayTasksRows[4][DayTasksTableKeys.dayTaskDayKey], '2025-08-23');
      expect(dayTasksRows[4][DayTasksTableKeys.dayTaskTaskKey], t1.taskId);
      expect(dayTasksRows[4][DayTasksTableKeys.dayTaskDoneKey], 1);
      expect(dayTasksRows[5][DayTasksTableKeys.dayTaskDayKey], '2025-08-23');
      expect(dayTasksRows[5][DayTasksTableKeys.dayTaskTaskKey], t2.taskId);
      expect(dayTasksRows[5][DayTasksTableKeys.dayTaskDoneKey], 0);
      expect(dayTasksRows[6][DayTasksTableKeys.dayTaskDayKey], '2025-08-23');
      expect(dayTasksRows[6][DayTasksTableKeys.dayTaskTaskKey], t5.taskId);
      expect(dayTasksRows[6][DayTasksTableKeys.dayTaskDoneKey], 0);

      // deletes the non-recurring task from today - check if correctly set in the db
      bloc.add(DeleteTaskEvent(dayId: '2025-08-23', taskId: t5.taskId));
      expect(
        await queue.next,
        TasksState(
          tasks: [
            t1.copyWith(isDone: true),
            t2.copyWith(content: 'updated 2'),
          ],
          isLoading: true,
          error: null,
        ),
      );
      expect(
        await queue.next,
        TasksState(
          tasks: [
            t1.copyWith(isDone: true),
            t2.copyWith(content: 'updated 2'),
          ],
          isLoading: false,
          error: null,
        ),
      );
      tasksRows = await db.query('tasks');
      dayTasksRows = await db.query('day_tasks');
      expect(tasksRows.length, 5);
      expect(TaskModel.fromMap(tasksRows[0]).toEntity(), t1);
      expect(
        TaskModel.fromMap(tasksRows[1]).toEntity(),
        t2.copyWith(content: 'updated 2'),
      );
      expect(
        TaskModel.fromMap(tasksRows[2]).toEntity(),
        t3.copyWith(isRecurring: false),
      );
      expect(TaskModel.fromMap(tasksRows[3]).toEntity(), t4);
      expect(TaskModel.fromMap(tasksRows[4]).toEntity(), t5);
      expect(dayTasksRows.length, 6);
      expect(dayTasksRows[0][DayTasksTableKeys.dayTaskDayKey], '2025-08-22');
      expect(dayTasksRows[0][DayTasksTableKeys.dayTaskTaskKey], t1.taskId);
      expect(dayTasksRows[0][DayTasksTableKeys.dayTaskDoneKey], 1);
      expect(dayTasksRows[1][DayTasksTableKeys.dayTaskDayKey], '2025-08-22');
      expect(dayTasksRows[1][DayTasksTableKeys.dayTaskTaskKey], t2.taskId);
      expect(dayTasksRows[1][DayTasksTableKeys.dayTaskDoneKey], 1);
      expect(dayTasksRows[2][DayTasksTableKeys.dayTaskDayKey], '2025-08-22');
      expect(dayTasksRows[2][DayTasksTableKeys.dayTaskTaskKey], t3.taskId);
      expect(dayTasksRows[2][DayTasksTableKeys.dayTaskDoneKey], 0);
      expect(dayTasksRows[3][DayTasksTableKeys.dayTaskDayKey], '2025-08-22');
      expect(dayTasksRows[3][DayTasksTableKeys.dayTaskTaskKey], t4.taskId);
      expect(dayTasksRows[3][DayTasksTableKeys.dayTaskDoneKey], 1);
      expect(dayTasksRows[4][DayTasksTableKeys.dayTaskDayKey], '2025-08-23');
      expect(dayTasksRows[4][DayTasksTableKeys.dayTaskTaskKey], t1.taskId);
      expect(dayTasksRows[4][DayTasksTableKeys.dayTaskDoneKey], 1);
      expect(dayTasksRows[5][DayTasksTableKeys.dayTaskDayKey], '2025-08-23');
      expect(dayTasksRows[5][DayTasksTableKeys.dayTaskTaskKey], t2.taskId);
      expect(dayTasksRows[5][DayTasksTableKeys.dayTaskDoneKey], 0);

      // reads tasks from previous day - check if they are all there, with the one updated correctly
      bloc.add(ReadTasksForDayEvent(dayId: '2025-08-22'));
      expect(
        await queue.next,
        TasksState(tasks: [], isLoading: true, error: null),
      );
      expect(
        await queue.next,
        TasksState(
          tasks: [
            t1.copyWith(isDone: true),
            t2.copyWith(content: 'updated 2', isDone: true),
            t3.copyWith(isRecurring: false),
            t4.copyWith(isDone: true),
          ],
          isLoading: false,
          error: null,
        ),
      );

      // initializes another day - check if it has only the 2 recurring tasks remaining, with the updated one
      bloc.add(InitializeTasksForDayEvent(dayId: '2025-08-24'));
      expect(
        await queue.next,
        TasksState(tasks: [], isLoading: true, error: null),
      );
      expect(
        await queue.next,
        TasksState(
          tasks: [
            t1,
            t2.copyWith(content: 'updated 2'),
          ],
          isLoading: false,
          error: null,
        ),
      );
      dayTasksRows = await db.query('day_tasks');
      expect(dayTasksRows.length, 8);
      expect(dayTasksRows[0][DayTasksTableKeys.dayTaskDayKey], '2025-08-22');
      expect(dayTasksRows[0][DayTasksTableKeys.dayTaskTaskKey], t1.taskId);
      expect(dayTasksRows[0][DayTasksTableKeys.dayTaskDoneKey], 1);
      expect(dayTasksRows[1][DayTasksTableKeys.dayTaskDayKey], '2025-08-22');
      expect(dayTasksRows[1][DayTasksTableKeys.dayTaskTaskKey], t2.taskId);
      expect(dayTasksRows[1][DayTasksTableKeys.dayTaskDoneKey], 1);
      expect(dayTasksRows[2][DayTasksTableKeys.dayTaskDayKey], '2025-08-22');
      expect(dayTasksRows[2][DayTasksTableKeys.dayTaskTaskKey], t3.taskId);
      expect(dayTasksRows[2][DayTasksTableKeys.dayTaskDoneKey], 0);
      expect(dayTasksRows[3][DayTasksTableKeys.dayTaskDayKey], '2025-08-22');
      expect(dayTasksRows[3][DayTasksTableKeys.dayTaskTaskKey], t4.taskId);
      expect(dayTasksRows[3][DayTasksTableKeys.dayTaskDoneKey], 1);
      expect(dayTasksRows[4][DayTasksTableKeys.dayTaskDayKey], '2025-08-23');
      expect(dayTasksRows[4][DayTasksTableKeys.dayTaskTaskKey], t1.taskId);
      expect(dayTasksRows[4][DayTasksTableKeys.dayTaskDoneKey], 1);
      expect(dayTasksRows[5][DayTasksTableKeys.dayTaskDayKey], '2025-08-23');
      expect(dayTasksRows[5][DayTasksTableKeys.dayTaskTaskKey], t2.taskId);
      expect(dayTasksRows[5][DayTasksTableKeys.dayTaskDoneKey], 0);
      expect(dayTasksRows[6][DayTasksTableKeys.dayTaskDayKey], '2025-08-24');
      expect(dayTasksRows[6][DayTasksTableKeys.dayTaskTaskKey], t1.taskId);
      expect(dayTasksRows[6][DayTasksTableKeys.dayTaskDoneKey], 0);
      expect(dayTasksRows[7][DayTasksTableKeys.dayTaskDayKey], '2025-08-24');
      expect(dayTasksRows[7][DayTasksTableKeys.dayTaskTaskKey], t2.taskId);
      expect(dayTasksRows[7][DayTasksTableKeys.dayTaskDoneKey], 0);

      // gets all tasks for current month - check if they are all there, including the deleted non-recurring
      bloc.add(ReadTasksForMonthEvent(monthId: '2025-08'));
      expect(
        await queue.next,
        TasksState(tasks: [], isLoading: true, error: null),
      );
      expect(
        await queue.next,
        TasksState(
          tasks: [
            t1,
            t2.copyWith(content: 'updated 2'),
            t3.copyWith(isRecurring: false),
            t4,
          ],
          isLoading: false,
          error: null,
        ),
      );

      // deletes a recurring task and a non-recurring task from first day - check if correctly deleted
      bloc.add(DeleteTaskEvent(dayId: null, taskId: t2.taskId));
      expect(
        await queue.next,
        TasksState(
          tasks: [t1, t3.copyWith(isRecurring: false), t4],
          isLoading: true,
          error: null,
        ),
      );
      expect(
        await queue.next,
        TasksState(
          tasks: [t1, t3.copyWith(isRecurring: false), t4],
          isLoading: false,
          error: null,
        ),
      );

      bloc.add(DeleteTaskEvent(dayId: null, taskId: t4.taskId));
      expect(
        await queue.next,
        TasksState(
          tasks: [t1, t3.copyWith(isRecurring: false)],
          isLoading: true,
          error: null,
        ),
      );
      expect(
        await queue.next,
        TasksState(
          tasks: [t1, t3.copyWith(isRecurring: false)],
          isLoading: false,
          error: null,
        ),
      );

      tasksRows = await db.query('tasks');
      dayTasksRows = await db.query('day_tasks');
      expect(tasksRows.length, 3);
      expect(TaskModel.fromMap(tasksRows[0]).toEntity(), t1);
      expect(
        TaskModel.fromMap(tasksRows[1]).toEntity(),
        t3.copyWith(isRecurring: false),
      );
      expect(TaskModel.fromMap(tasksRows[2]).toEntity(), t5);
      expect(dayTasksRows.length, 4);
      expect(dayTasksRows[0][DayTasksTableKeys.dayTaskDayKey], '2025-08-22');
      expect(dayTasksRows[0][DayTasksTableKeys.dayTaskTaskKey], t1.taskId);
      expect(dayTasksRows[0][DayTasksTableKeys.dayTaskDoneKey], 1);
      expect(dayTasksRows[1][DayTasksTableKeys.dayTaskDayKey], '2025-08-22');
      expect(dayTasksRows[1][DayTasksTableKeys.dayTaskTaskKey], t3.taskId);
      expect(dayTasksRows[1][DayTasksTableKeys.dayTaskDoneKey], 0);
      expect(dayTasksRows[2][DayTasksTableKeys.dayTaskDayKey], '2025-08-23');
      expect(dayTasksRows[2][DayTasksTableKeys.dayTaskTaskKey], t1.taskId);
      expect(dayTasksRows[2][DayTasksTableKeys.dayTaskDoneKey], 1);
      expect(dayTasksRows[3][DayTasksTableKeys.dayTaskDayKey], '2025-08-24');
      expect(dayTasksRows[3][DayTasksTableKeys.dayTaskTaskKey], t1.taskId);
      expect(dayTasksRows[3][DayTasksTableKeys.dayTaskDoneKey], 0);

      // reads tasks from first day - check if the recurring and non-recurring are gone
      bloc.add(ReadTasksForDayEvent(dayId: '2025-08-22'));
      expect(
        await queue.next,
        TasksState(tasks: [], isLoading: true, error: null),
      );
      expect(
        await queue.next,
        TasksState(
          tasks: [t1.copyWith(isDone: true), t3.copyWith(isRecurring: false)],
          isLoading: false,
          error: null,
        ),
      );

      // initializes another day - check if correctly initialized
      bloc.add(InitializeTasksForDayEvent(dayId: '2025-08-25'));
      expect(
        await queue.next,
        TasksState(tasks: [], isLoading: true, error: null),
      );
      expect(
        await queue.next,
        TasksState(
          tasks: [t1],
          isLoading: false,
          error: null,
        ),
      );

      await queue.cancel();
    },
  );
}
