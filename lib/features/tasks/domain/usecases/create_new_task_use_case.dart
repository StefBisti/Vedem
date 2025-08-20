import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:vedem/core/error/failures.dart';
import 'package:vedem/core/usecase/usecase.dart';
import 'package:vedem/features/tasks/domain/entities/task_entity.dart';
import 'package:vedem/features/tasks/domain/repositories/task_repository.dart';

class CreateNewTaskUseCase
    implements UseCase<TaskEntity, CreateNewTaskUseCaseParams> {
  final TaskRepository taskRepository;

  const CreateNewTaskUseCase({required this.taskRepository});

  @override
  Future<Either<Failure, TaskEntity>> call(
    CreateNewTaskUseCaseParams params,
  ) async {
    // check if data is right
    return await taskRepository.createNewTaskAndAssignToDay(
      params.dayId,
      params.categoryId,
      params.content,
      params.isRecurring,
      params.diamonds,
    );
  }
}

class CreateNewTaskUseCaseParams extends Equatable {
  final String dayId;
  final int categoryId;
  final String content;
  final bool isRecurring;
  final int diamonds;

  const CreateNewTaskUseCaseParams({
    required this.dayId,
    required this.categoryId,
    required this.content,
    required this.isRecurring,
    required this.diamonds,
  });

  @override
  List<Object?> get props => [
    dayId,
    categoryId,
    content,
    isRecurring,
    diamonds,
  ];
}
