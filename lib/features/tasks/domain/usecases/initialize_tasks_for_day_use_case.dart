import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:vedem/core/error/failures.dart';
import 'package:vedem/core/usecase/usecase.dart';
import 'package:vedem/features/tasks/domain/entities/task_entity.dart';
import 'package:vedem/features/tasks/domain/repositories/task_repository.dart';

class InitializeTasksForDayUseCase
    implements UseCase<List<TaskEntity>, InitializeTasksForDayUseCaseParams> {
  final TaskRepository taskRepository;

  const InitializeTasksForDayUseCase({required this.taskRepository});

  @override
  Future<Either<Failure, List<TaskEntity>>> call(
    InitializeTasksForDayUseCaseParams params,
  ) async {
    return await taskRepository.initializeTasksForDay(params.dayId);
  }
}

class InitializeTasksForDayUseCaseParams extends Equatable {
  final String dayId;

  const InitializeTasksForDayUseCaseParams({required this.dayId});
  
  @override
  List<Object?> get props => [dayId];
}
