import 'package:fpdart/fpdart.dart';
import 'package:vedem/core/error/failures.dart';
import 'package:vedem/core/usecase/usecase.dart';
import 'package:vedem/features/rich_inputs/domain/entities/rich_input_entity.dart';
import 'package:vedem/features/rich_inputs/domain/repositories/rich_inputs_repository.dart';

class SaveRichInputUseCase
    implements UseCase<Unit, SaveRichInputUseCaseParams> {
  final RichInputsRepository repository;

  const SaveRichInputUseCase({required this.repository});

  @override
  Future<Either<Failure, Unit>> call(SaveRichInputUseCaseParams params) {
    return repository.saveRichInput(params.key, params.newRichInput);
  }
}

class SaveRichInputUseCaseParams {
  final String key;
  final RichInputEntity newRichInput;

  const SaveRichInputUseCaseParams({
    required this.key,
    required this.newRichInput,
  });
}

class DelayedSaveRichInputUseCase extends SaveRichInputUseCase {
  final Duration delay = Duration(milliseconds: delayedUseCaseMilliseconds);

  DelayedSaveRichInputUseCase({required super.repository});

  @override
  Future<Either<Failure, Unit>> call(SaveRichInputUseCaseParams params) async {
    await Future.delayed(delay);
    return super.call(params);
  }
}
