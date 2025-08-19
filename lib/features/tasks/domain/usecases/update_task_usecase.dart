import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:vedem/core/error/failures.dart';
import 'package:vedem/core/usecase/usecase.dart';
import 'package:vedem/features/tasks/domain/entities/task_entity.dart';
import 'package:vedem/features/tasks/domain/repositories/task_repository.dart';

class UpdateTaskUsecase implements UseCase<Unit, UpdateTaskUsecaseParams> {
  final TaskRepository taskRepository;

  const UpdateTaskUsecase({required this.taskRepository});

  @override
  Future<Either<Failure, Unit>> call(UpdateTaskUsecaseParams params) async {
    return await taskRepository.updateTask(params.newTask);
  }
}

class UpdateTaskUsecaseParams extends Equatable {
  final TaskEntity newTask;

  const UpdateTaskUsecaseParams({required this.newTask});

  @override
  List<Object?> get props => [newTask];
}
