import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:vedem/features/tasks/data/datasources/task_local_data_source.dart';
import 'package:vedem/features/tasks/data/repositories/task_repository_impl.dart';
// import 'package:vedem/features/tasks/domain/entities/task_entity.dart';
import 'package:vedem/features/tasks/domain/usecases/create_new_task_use_case.dart';
import 'package:vedem/features/tasks/domain/usecases/delete_task_usecase.dart';
import 'package:vedem/features/tasks/domain/usecases/initialize_tasks_for_day_use_case.dart';
import 'package:vedem/features/tasks/domain/usecases/read_tasks_for_day_usecase.dart';
import 'package:vedem/features/tasks/domain/usecases/set_task_usecase.dart';
import 'package:vedem/features/tasks/domain/usecases/update_task_usecase.dart';
import 'package:vedem/features/tasks/presentation/bloc/tasks_bloc.dart';

void main() {
  late Database db;
  late TaskLocalDataSource dataSource;
  late TaskRepositoryImpl repo;
  late CreateNewTaskUseCase createNewTaskUseCase;
  late DeleteTaskUseCase deleteTaskUseCase;
  late InitializeTasksForDayUseCase initializeTasksForDayUseCase;
  late ReadTasksForDayUseCase readTasksForDayUseCase;
  late SetTaskUseCase setTaskUseCase;
  late UpdateTaskUseCase updateTaskUseCase;
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
            CREATE TABLE tasks (
              task_id INTEGER PRIMARY KEY AUTOINCREMENT,
              category_id INTEGER NOT NULL,
              content TEXT NOT NULL,
              is_recurring INTEGER NOT NULL,
              diamonds INTEGER NOT NULL
            )
          ''');
          await db.execute('''
            CREATE TABLE day_tasks (
              day_task_id INTEGER PRIMARY KEY AUTOINCREMENT,
              day_id TEXT NOT NULL,
              task_id INTEGER NOT NULL,
              done INTEGER NOT NULL DEFAULT 0,
              FOREIGN KEY (task_id) REFERENCES tasks (task_id)
            );
          ''');
          await db.execute(
            'CREATE INDEX idx_tasks_category_id ON tasks(category_id);',
          );
          await db.execute(
            'CREATE INDEX idx_day_tasks_task_id ON day_tasks(task_id);',
          );
          await db.execute(
            'CREATE INDEX idx_day_tasks_day_id ON day_tasks(day_id);',
          );
        },
      ),
    );
    dataSource = TaskLocalDataSource(db: db);
    repo = TaskRepositoryImpl(dataSource: dataSource);
    createNewTaskUseCase = CreateNewTaskUseCase(taskRepository: repo);
    initializeTasksForDayUseCase = InitializeTasksForDayUseCase(
      taskRepository: repo,
    );
    readTasksForDayUseCase = ReadTasksForDayUseCase(taskRepository: repo);
    updateTaskUseCase = UpdateTaskUseCase(taskRepository: repo);
    deleteTaskUseCase = DeleteTaskUseCase(taskRepository: repo);
    setTaskUseCase = SetTaskUseCase(taskRepository: repo);
    bloc = TasksBloc(
      createNewTaskUseCase: createNewTaskUseCase,
      initializeTasksForDayUseCase: initializeTasksForDayUseCase,
      readTasksForDayUseCase: readTasksForDayUseCase,
      updateTaskUseCase: updateTaskUseCase,
      deleteTaskUseCase: deleteTaskUseCase,
      setTaskUseCase: setTaskUseCase,
    );
  });

  tearDown(() async {
    await bloc.close();
    await db.close();
  });

  // final TaskEntity sampleTask1 = TaskEntity(
  //   taskId: 1,
  //   categoryId: 1,
  //   content: 'test 1',
  //   isRecurring: true,
  //   diamonds: 11,
  //   isDone: false,
  // );
  // final TaskEntity sampleTask2 = TaskEntity(
  //   taskId: 2,
  //   categoryId: 2,
  //   content: 'test 2',
  //   isRecurring: false,
  //   diamonds: 22,
  //   isDone: false,
  // );
  // final String sampleDayId = '2025-08-18';

  test('default', () async {
    
  });
}
