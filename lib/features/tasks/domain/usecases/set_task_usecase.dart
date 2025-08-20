import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:vedem/core/error/failures.dart';
import 'package:vedem/core/usecase/usecase.dart';
import 'package:vedem/features/tasks/domain/repositories/task_repository.dart';

class SetTaskUseCase implements UseCase<Unit, SetTaskUseCaseParams> {
  final TaskRepository taskRepository;

  const SetTaskUseCase({required this.taskRepository});

  @override
  Future<Either<Failure, Unit>> call(SetTaskUseCaseParams params) async {
    return await taskRepository.setTask(
      params.dayId,
      params.taskId,
      params.completed,
    );
  }
}

class SetTaskUseCaseParams extends Equatable {
  final String dayId;
  final int taskId;
  final bool completed;

  const SetTaskUseCaseParams({
    required this.dayId,
    required this.taskId,
    required this.completed,
  });
  
  @override
  List<Object?> get props => [dayId, taskId, completed];
}
