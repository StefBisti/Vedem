import 'package:fpdart/fpdart.dart';
import 'package:vedem/core/error/failures.dart';
import 'package:vedem/core/usecase/usecase.dart';
import 'package:vedem/features/tasks/domain/entities/task_entity.dart';
import 'package:vedem/features/tasks/domain/repositories/task_repository.dart';

class UpdateTaskUsecase
    implements UseCase<TaskEntity, UpdateTaskUsecaseParams> {
  final TaskRepository taskRepository;

  const UpdateTaskUsecase({required this.taskRepository});

  @override
  Future<Either<Failure, TaskEntity>> call(
    UpdateTaskUsecaseParams params,
  ) async {
    return await taskRepository.updateTask(
      params.taskId,
      params.categoryId,
      params.content,
      params.diamonds,
      params.isRecurring,
    );
  }
}

class UpdateTaskUsecaseParams {
  final int taskId;
  final int categoryId;
  final String content;
  final int diamonds;
  final bool isRecurring;

  const UpdateTaskUsecaseParams({
    required this.taskId,
    required this.categoryId,
    required this.content,
    required this.diamonds,
    required this.isRecurring,
  });
}
