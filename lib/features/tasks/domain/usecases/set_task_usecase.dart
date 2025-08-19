import 'package:fpdart/fpdart.dart';
import 'package:vedem/core/error/failures.dart';
import 'package:vedem/core/error/success.dart';
import 'package:vedem/core/usecase/usecase.dart';
import 'package:vedem/features/tasks/domain/repositories/task_repository.dart';

class SetTaskUsecase implements UseCase<Success, SetTaskUsecaseParams> {
  final TaskRepository taskRepository;

  const SetTaskUsecase({required this.taskRepository});

  @override
  Future<Either<Failure, Success>> call(SetTaskUsecaseParams params) async {
    return await taskRepository.setTask(
      params.dayId,
      params.taskId,
      params.completed,
    );
  }
}

class SetTaskUsecaseParams {
  final String dayId;
  final int taskId;
  final bool completed;

  const SetTaskUsecaseParams({
    required this.dayId,
    required this.taskId,
    required this.completed,
  });
}
