import 'package:fpdart/fpdart.dart';
import 'package:vedem/core/error/failures.dart';
import 'package:vedem/core/usecase/usecase.dart';
import 'package:vedem/features/tasks/domain/entities/task_entity.dart';
import 'package:vedem/features/tasks/domain/repositories/task_repository.dart';

class ReadTasksForDayUsecase
    implements UseCase<List<TaskEntity>, ReadTasksForDayUsecaseParams> {
  final TaskRepository taskRepository;

  const ReadTasksForDayUsecase({required this.taskRepository});

  @override
  Future<Either<Failure, List<TaskEntity>>> call(
    ReadTasksForDayUsecaseParams params,
  ) async {
    return await taskRepository.readTasksForDay(params.dayId);
  }
}

class ReadTasksForDayUsecaseParams {
  final String dayId;

  const ReadTasksForDayUsecaseParams({required this.dayId});
}
