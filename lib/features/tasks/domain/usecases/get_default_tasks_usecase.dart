import 'package:fpdart/fpdart.dart';
import 'package:vedem/core/error/failures.dart';
import 'package:vedem/core/usecase/usecase.dart';
import 'package:vedem/features/tasks/domain/entities/task_entity.dart';
import 'package:vedem/features/tasks/domain/repositories/task_repository.dart';

class GetDefaultTasksUsecase
    implements UseCase<List<TaskEntity>, GetDefaultTasksUsecaseParams> {
  final TaskRepository taskRepository;

  const GetDefaultTasksUsecase({required this.taskRepository});

  @override
  Future<Either<Failure, List<TaskEntity>>> call(
    GetDefaultTasksUsecaseParams params,
  ) async {
    return await taskRepository.getDefaultTasks(params.dayId);
  }
}

class GetDefaultTasksUsecaseParams {
  final String dayId;

  const GetDefaultTasksUsecaseParams({required this.dayId});
}
