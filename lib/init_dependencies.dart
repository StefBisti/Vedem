import 'dart:io';
import 'package:get_it/get_it.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:vedem/core/database/app_database.dart';
import 'package:vedem/features/tasks/data/datasources/task_data_source.dart';
import 'package:vedem/features/tasks/data/datasources/task_local_data_source.dart';
import 'package:vedem/features/tasks/data/repositories/task_repository_impl.dart';
import 'package:vedem/features/tasks/domain/repositories/task_repository.dart';
import 'package:vedem/features/tasks/domain/usecases/create_new_task_use_case.dart';
import 'package:vedem/features/tasks/domain/usecases/delete_task_usecase.dart';
import 'package:vedem/features/tasks/domain/usecases/initialize_tasks_for_day_use_case.dart';
import 'package:vedem/features/tasks/domain/usecases/read_tasks_for_day_usecase.dart';
import 'package:vedem/features/tasks/domain/usecases/read_tasks_for_month_use_case.dart';
import 'package:vedem/features/tasks/domain/usecases/set_task_usecase.dart';
import 'package:vedem/features/tasks/domain/usecases/update_task_usecase.dart';
import 'package:vedem/features/tasks/presentation/bloc/tasks_bloc.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  await _initTasks();
}

Future<void> _initTasks() async {
  serviceLocator.registerFactory(
    () => TasksBloc(
      createNewTaskUseCase: serviceLocator(),
      initializeTasksForDayUseCase: serviceLocator(),
      readTasksForDayUseCase: serviceLocator(),
      readTasksForMonthUseCase: serviceLocator(),
      updateTaskUseCase: serviceLocator(),
      deleteTaskUseCase: serviceLocator(),
      setTaskUseCase: serviceLocator(),
    ),
  );

  // Usecases
  serviceLocator.registerLazySingleton(
    () => CreateNewTaskUseCase(taskRepository: serviceLocator()),
  );
  serviceLocator.registerLazySingleton(
    () => InitializeTasksForDayUseCase(taskRepository: serviceLocator()),
  );
  serviceLocator.registerLazySingleton(
    () => ReadTasksForDayUseCase(taskRepository: serviceLocator()),
  );
  serviceLocator.registerLazySingleton(
    () => ReadTasksForMonthUseCase(taskRepository: serviceLocator()),
  );
  serviceLocator.registerLazySingleton(
    () => UpdateTaskUseCase(taskRepository: serviceLocator()),
  );
  serviceLocator.registerLazySingleton(
    () => DeleteTaskUseCase(taskRepository: serviceLocator()),
  );
  serviceLocator.registerLazySingleton(
    () => SetTaskUseCase(taskRepository: serviceLocator()),
  );

  // Repository
  serviceLocator.registerLazySingleton<TaskRepository>(
    () => TaskRepositoryImpl(dataSource: serviceLocator()),
  );

  // Data sources
  serviceLocator.registerLazySingleton<TaskDataSource>(
    () => TaskLocalDataSource(db: serviceLocator()),
  );

  // External
  Directory documentsDirectory = await getApplicationDocumentsDirectory();
  final path = join(documentsDirectory.path, 'my_app.db');
  final db = await AppDatabase.open(path);
  serviceLocator.registerLazySingleton<Database>(() => db);
}
