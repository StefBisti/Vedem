import 'package:fpdart/fpdart.dart';
import 'package:vedem/core/error/failures.dart';
import 'package:vedem/core/usecase/usecase.dart';
import 'package:vedem/features/rich_inputs/domain/entities/rich_input_entity.dart';
import 'package:vedem/features/rich_inputs/domain/repositories/rich_inputs_repository.dart';

class LoadRichInputUseCase
    implements UseCase<RichInputEntity, LoadRichInputUseCaseParams> {
  final RichInputsRepository repository;

  const LoadRichInputUseCase({required this.repository});

  @override
  Future<Either<Failure, RichInputEntity>> call(
    LoadRichInputUseCaseParams params,
  ) {
    return repository.loadRichInput(params.key);
  }
}

class LoadRichInputUseCaseParams {
  final String key;

  const LoadRichInputUseCaseParams({required this.key});
}

class DelayedLoadRichInputUseCase extends LoadRichInputUseCase {
  final Duration delay = Duration(milliseconds: delayedUseCaseMilliseconds);

  DelayedLoadRichInputUseCase({required super.repository});

  @override
  Future<Either<Failure, RichInputEntity>> call(
    LoadRichInputUseCaseParams params,
  ) async {
    await Future.delayed(delay);
    return super.call(params);
  }
}
