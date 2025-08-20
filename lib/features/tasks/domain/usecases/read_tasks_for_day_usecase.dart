import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:vedem/core/error/failures.dart';
import 'package:vedem/core/usecase/usecase.dart';
import 'package:vedem/features/tasks/domain/entities/task_entity.dart';
import 'package:vedem/features/tasks/domain/repositories/task_repository.dart';

class ReadTasksForDayUseCase
    implements UseCase<List<TaskEntity>, ReadTasksForDayUseCaseParams> {
  final TaskRepository taskRepository;

  const ReadTasksForDayUseCase({required this.taskRepository});

  @override
  Future<Either<Failure, List<TaskEntity>>> call(
    ReadTasksForDayUseCaseParams params,
  ) async {
    return await taskRepository.readTasksForDay(params.dayId);
  }
}

class ReadTasksForDayUseCaseParams extends Equatable {
  final String dayId;

  const ReadTasksForDayUseCaseParams({required this.dayId});
  
  @override
  List<Object?> get props => [dayId];
}
