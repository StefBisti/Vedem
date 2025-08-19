import 'package:fpdart/fpdart.dart';
import 'package:vedem/core/error/failures.dart';
import 'package:vedem/core/error/success.dart';
import 'package:vedem/core/usecase/usecase.dart';
import 'package:vedem/features/tasks/domain/entities/task_entity.dart';
import 'package:vedem/features/tasks/domain/repositories/task_repository.dart';

class UpdateTaskUsecase implements UseCase<Success, UpdateTaskUsecaseParams> {
  final TaskRepository taskRepository;

  const UpdateTaskUsecase({required this.taskRepository});

  @override
  Future<Either<Failure, Success>> call(UpdateTaskUsecaseParams params) async {
    return await taskRepository.updateTask(params.newTask);
  }
}

class UpdateTaskUsecaseParams {
  final TaskEntity newTask;

  const UpdateTaskUsecaseParams({required this.newTask});
}
