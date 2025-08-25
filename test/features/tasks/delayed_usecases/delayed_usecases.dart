import 'package:fpdart/fpdart.dart';
import 'package:vedem/core/error/failures.dart';
import 'package:vedem/features/tasks/domain/entities/task_entity.dart';
import 'package:vedem/features/tasks/domain/usecases/create_new_task_use_case.dart';
import 'package:vedem/features/tasks/domain/usecases/delete_task_usecase.dart';
import 'package:vedem/features/tasks/domain/usecases/initialize_tasks_for_day_use_case.dart';
import 'package:vedem/features/tasks/domain/usecases/read_tasks_for_day_usecase.dart';
import 'package:vedem/features/tasks/domain/usecases/read_tasks_for_month_use_case.dart';
import 'package:vedem/features/tasks/domain/usecases/set_task_usecase.dart';
import 'package:vedem/features/tasks/domain/usecases/update_task_usecase.dart';

int delayedMillisecondsDuration = 0;

class DelayedCreateNewTaskUseCase extends CreateNewTaskUseCase {
  final Duration delay = Duration(milliseconds: delayedMillisecondsDuration);

  DelayedCreateNewTaskUseCase({required super.taskRepository});

  @override
  Future<Either<Failure, TaskEntity>> call(
    CreateNewTaskUseCaseParams params,
  ) async {
    await Future.delayed(delay);
    return super.call(params);
  }
}

class DelayedDeleteTaskUseCase extends DeleteTaskUseCase {
  final Duration delay = Duration(milliseconds: delayedMillisecondsDuration);

  DelayedDeleteTaskUseCase({required super.taskRepository});

  @override
  Future<Either<Failure, Unit>> call(
    DeleteTaskUseCaseParams params,
  ) async {
    await Future.delayed(delay);
    return super.call(params);
  }
}

class DelayedReadTasksForDayUseCase extends ReadTasksForDayUseCase {
  final Duration delay = Duration(milliseconds: delayedMillisecondsDuration);

  DelayedReadTasksForDayUseCase({required super.taskRepository});

  @override
  Future<Either<Failure, List<TaskEntity>>> call(
    ReadTasksForDayUseCaseParams params,
  ) async {
    await Future.delayed(delay);
    return super.call(params);
  }
}

class DelayedInitializeTasksForDayUseCase extends InitializeTasksForDayUseCase {
  final Duration delay = Duration(milliseconds: delayedMillisecondsDuration);

  DelayedInitializeTasksForDayUseCase({required super.taskRepository});

  @override
  Future<Either<Failure, List<TaskEntity>>> call(
    InitializeTasksForDayUseCaseParams params,
  ) async {
    await Future.delayed(delay);
    return super.call(params);
  }
}

class DelayedReadTasksForMonthUseCase extends ReadTasksForMonthUseCase {
  final Duration delay = Duration(milliseconds: delayedMillisecondsDuration);

  DelayedReadTasksForMonthUseCase({required super.taskRepository});

  @override
  Future<Either<Failure, List<TaskEntity>>> call(
    ReadTasksForMonthUseCaseParams params,
  ) async {
    await Future.delayed(delay);
    return super.call(params);
  }
}

class DelayedSetTaskUseCase extends SetTaskUseCase {
  final Duration delay = Duration(milliseconds: delayedMillisecondsDuration);

  DelayedSetTaskUseCase({required super.taskRepository});

  @override
  Future<Either<Failure, Unit>> call(
    SetTaskUseCaseParams params,
  ) async {
    await Future.delayed(delay);
    return super.call(params);
  }
}

class DelayedUpdateTaskUseCase extends UpdateTaskUseCase {
  final Duration delay = Duration(milliseconds: delayedMillisecondsDuration);

  DelayedUpdateTaskUseCase({required super.taskRepository});

  @override
  Future<Either<Failure, Unit>> call(
    UpdateTaskUseCaseParams params,
  ) async {
    await Future.delayed(delay);
    return super.call(params);
  }
}