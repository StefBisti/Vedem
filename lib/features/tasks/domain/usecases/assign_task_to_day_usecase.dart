import 'package:fpdart/fpdart.dart';
import 'package:vedem/core/error/failures.dart';
import 'package:vedem/core/usecase/usecase.dart';
import 'package:vedem/features/tasks/domain/repositories/task_repository.dart';

class AssignTaskToDayUsecase
    implements UseCase<Unit, AssignTaskToDayUsecaseParams> {
  final TaskRepository taskRepository;

  const AssignTaskToDayUsecase({required this.taskRepository});
  @override
  Future<Either<Failure, Unit>> call(
    AssignTaskToDayUsecaseParams params,
  ) async {
    return await taskRepository.assignTaskToDay(params.dayId, params.taskId);
  }
}

class AssignTaskToDayUsecaseParams {
  final String dayId;
  final int taskId;

  const AssignTaskToDayUsecaseParams({
    required this.dayId,
    required this.taskId,
  });
}
