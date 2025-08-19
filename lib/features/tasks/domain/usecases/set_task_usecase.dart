import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:vedem/core/error/failures.dart';
import 'package:vedem/core/usecase/usecase.dart';
import 'package:vedem/features/tasks/domain/repositories/task_repository.dart';

class SetTaskUsecase implements UseCase<Unit, SetTaskUsecaseParams> {
  final TaskRepository taskRepository;

  const SetTaskUsecase({required this.taskRepository});

  @override
  Future<Either<Failure, Unit>> call(SetTaskUsecaseParams params) async {
    return await taskRepository.setTask(
      params.dayId,
      params.taskId,
      params.completed,
    );
  }
}

class SetTaskUsecaseParams extends Equatable {
  final String dayId;
  final int taskId;
  final bool completed;

  const SetTaskUsecaseParams({
    required this.dayId,
    required this.taskId,
    required this.completed,
  });
  
  @override
  List<Object?> get props => [dayId, taskId, completed];
}
