import 'dart:io';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:vedem/core/database/app_database.dart';
import 'package:vedem/core/hive/app_hive.dart';
import 'package:vedem/features/highlights/data/datasources/highlights_data_source.dart';
import 'package:vedem/features/highlights/data/datasources/highlights_local_data_source.dart';
import 'package:vedem/features/highlights/data/models/highlight_model.dart';
import 'package:vedem/features/highlights/data/repositories/highlights_repository_impl.dart';
import 'package:vedem/features/highlights/domain/repositories/highlights_repository.dart';
import 'package:vedem/features/highlights/domain/usecases/cache_highlights_use_case.dart';
import 'package:vedem/features/highlights/domain/usecases/change_highlight_use_case.dart';
import 'package:vedem/features/highlights/domain/usecases/delete_highlight_use_case.dart';
import 'package:vedem/features/highlights/domain/usecases/load_all_highlights_metadata_use_case.dart';
import 'package:vedem/features/highlights/domain/usecases/load_month_highlights_metadata_use_case.dart';
import 'package:vedem/features/highlights/presentation/cubit/highlights_cubit.dart';
import 'package:vedem/features/rich_inputs/data/datasources/rich_inputs_data_source.dart';
import 'package:vedem/features/rich_inputs/data/datasources/rich_inputs_local_data_source.dart';
import 'package:vedem/features/rich_inputs/data/models/rich_input_model.dart';
import 'package:vedem/features/rich_inputs/data/repositories/rich_inputs_repository_impl.dart';
import 'package:vedem/features/rich_inputs/domain/repositories/rich_inputs_repository.dart';
import 'package:vedem/features/rich_inputs/domain/usecases/load_rich_input_use_case.dart';
import 'package:vedem/features/rich_inputs/domain/usecases/save_rich_input_use_case.dart';
import 'package:vedem/features/rich_inputs/presentation/cubit/rich_inputs_cubit.dart';
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
  await AppHive.initHive();
  await _initTasks();
  await _initRichInputs();
  await _initHighlights();
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

Future<void> _initRichInputs() async {
  serviceLocator.registerFactory(
    () => RichInputsCubit(
      loadRichInputUseCase: serviceLocator(),
      saveRichInputUseCase: serviceLocator(),
    ),
  );

  // Usecases
  serviceLocator.registerLazySingleton(
    () => LoadRichInputUseCase(repository: serviceLocator()),
  );
  serviceLocator.registerLazySingleton(
    () => SaveRichInputUseCase(repository: serviceLocator()),
  );

  // Repository
  serviceLocator.registerLazySingleton<RichInputsRepository>(
    () => RichInputsRepositoryImpl(dataSource: serviceLocator()),
  );

  // Data sources
  serviceLocator.registerLazySingleton<RichInputsDataSource>(
    () => RichInputsLocalDataSource(box: serviceLocator()),
  );

  // External
  Box<RichInputModel> box = await AppHive.initRichInputs();
  serviceLocator.registerLazySingleton<Box<RichInputModel>>(() => box);
}

Future<void> _initHighlights() async {
  serviceLocator.registerFactory(
    () => HighlightsCubit(
      serviceLocator(),
      serviceLocator(),
      serviceLocator(),
      serviceLocator(),
      serviceLocator(),
    ),
  );

  // Usecases
  serviceLocator.registerLazySingleton(
    () => CacheHighlightsUseCase(repository: serviceLocator()),
  );
  serviceLocator.registerLazySingleton(
    () => LoadAllHighlightsMetadataUseCase(repository: serviceLocator()),
  );
  serviceLocator.registerLazySingleton(
    () => LoadMonthHighlightsMetadataUseCase(repository: serviceLocator()),
  );
  serviceLocator.registerLazySingleton(
    () => ChangeHighlightUseCase(repository: serviceLocator()),
  );
  serviceLocator.registerLazySingleton(
    () => DeleteHighlightUseCase(repository: serviceLocator()),
  );

  // Repository
  serviceLocator.registerLazySingleton<HighlightsRepository>(
    () => HighlightsRepositoryImpl(dataSource: serviceLocator()),
  );

  // Data sources
  serviceLocator.registerLazySingleton<HighlightsDataSource>(
    () => HighlightsLocalDataSource(box: serviceLocator()),
  );

  // External
  Box<HighlightModel> box = await AppHive.initHighlights();
  serviceLocator.registerLazySingleton<Box<HighlightModel>>(() => box);
}
