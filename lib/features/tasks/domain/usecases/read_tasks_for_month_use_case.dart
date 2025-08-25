import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:vedem/core/error/failures.dart';
import 'package:vedem/core/usecase/usecase.dart';
import 'package:vedem/features/tasks/domain/entities/task_entity.dart';
import 'package:vedem/features/tasks/domain/repositories/task_repository.dart';

class ReadTasksForMonthUseCase
    implements UseCase<List<TaskEntity>, ReadTasksForMonthUseCaseParams> {
  final TaskRepository taskRepository;

  const ReadTasksForMonthUseCase({required this.taskRepository});

  @override
  Future<Either<Failure, List<TaskEntity>>> call(
    ReadTasksForMonthUseCaseParams params,
  ) async {
    return await taskRepository.readTasksForMonth(params.monthId);
  }
}

class ReadTasksForMonthUseCaseParams extends Equatable {
  final String monthId;

  const ReadTasksForMonthUseCaseParams({required this.monthId});

  @override
  List<Object?> get props => [monthId];
}
