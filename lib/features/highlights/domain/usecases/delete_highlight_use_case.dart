import 'package:fpdart/fpdart.dart';
import 'package:vedem/core/error/failures.dart';
import 'package:vedem/core/usecase/usecase.dart';
import 'package:vedem/features/highlights/domain/repositories/highlights_repository.dart';

class DeleteHighlightUseCase
    implements UseCase<Unit, DeleteHighlightUseCaseParams> {
  final HighlightsRepository repository;

  const DeleteHighlightUseCase({required this.repository});
  @override
  Future<Either<Failure, Unit>> call(DeleteHighlightUseCaseParams params) {
    return repository.deleteHighlight(params.dayId);
  }
}

class DeleteHighlightUseCaseParams {
  final String dayId;

  const DeleteHighlightUseCaseParams({required this.dayId});
}
