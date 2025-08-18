import 'package:fpdart/fpdart.dart';
import 'package:vedem/core/error/failures.dart';
import 'package:vedem/core/usecase/usecase.dart';
import 'package:vedem/features/tasks/domain/entities/task_entity.dart';
import 'package:vedem/features/tasks/domain/repositories/task_repository.dart';

class DeleteTaskUsecase
    implements UseCase<TaskEntity, DeleteTaskUsecaseParams> {
  final TaskRepository taskRepository;

  const DeleteTaskUsecase({required this.taskRepository});
  @override
  Future<Either<Failure, TaskEntity>> call(
    DeleteTaskUsecaseParams params,
  ) async {
    return await taskRepository.deleteTask(params.dayId, params.taskId);
  }
}

class DeleteTaskUsecaseParams {
  final String dayId;
  final int taskId;

  const DeleteTaskUsecaseParams({required this.dayId, required this.taskId});
}
