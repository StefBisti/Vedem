import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:vedem/core/error/failures.dart';
import 'package:vedem/core/usecase/usecase.dart';
import 'package:vedem/features/tasks/domain/repositories/task_repository.dart';

class DeleteTaskUseCase implements UseCase<Unit, DeleteTaskUseCaseParams> {
  final TaskRepository taskRepository;

  const DeleteTaskUseCase({required this.taskRepository});

  @override
  Future<Either<Failure, Unit>> call(DeleteTaskUseCaseParams params) async {
    return await taskRepository.deleteTask(
      params.dayId,
      params.taskId,
      params.isRecurring,
    );
  }
}

class DeleteTaskUseCaseParams extends Equatable {
  final String? dayId;
  final int taskId;
  final bool isRecurring;

  const DeleteTaskUseCaseParams({
    required this.dayId,
    required this.taskId,
    required this.isRecurring,
  });

  @override
  List<Object?> get props => [dayId ?? '', taskId, isRecurring];
}
