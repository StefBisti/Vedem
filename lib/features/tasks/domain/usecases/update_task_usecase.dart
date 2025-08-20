import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:vedem/core/error/failures.dart';
import 'package:vedem/core/usecase/usecase.dart';
import 'package:vedem/features/tasks/domain/repositories/task_repository.dart';

class UpdateTaskUseCase implements UseCase<Unit, UpdateTaskUseCaseParams> {
  final TaskRepository taskRepository;

  const UpdateTaskUseCase({required this.taskRepository});

  @override
  Future<Either<Failure, Unit>> call(UpdateTaskUseCaseParams params) async {
    return await taskRepository.updateTask(
      params.taskId,
      params.categoryId,
      params.content,
      params.isRecurring,
      params.diamonds,
    );
  }
}

class UpdateTaskUseCaseParams extends Equatable {
  final int taskId;
  final int categoryId;
  final String content;
  final bool isRecurring;
  final int diamonds;

  const UpdateTaskUseCaseParams({
    required this.taskId,
    required this.categoryId,
    required this.content,
    required this.isRecurring,
    required this.diamonds,
  });

  @override
  List<Object?> get props => [
    taskId,
    categoryId,
    content,
    isRecurring,
    diamonds,
  ];
}
