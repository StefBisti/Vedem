import 'package:fpdart/fpdart.dart';
import 'package:vedem/core/error/failures.dart';
import 'package:vedem/core/usecase/usecase.dart';
import 'package:vedem/features/highlights/domain/entities/highlight_entity.dart';
import 'package:vedem/features/highlights/domain/repositories/highlights_repository.dart';

class ChangeHighlightUseCase
    implements UseCase<HighlightEntity, ChangeHighlightUseCaseParams> {
  final HighlightsRepository repository;

  const ChangeHighlightUseCase({required this.repository});
  @override
  Future<Either<Failure, HighlightEntity>> call(
    ChangeHighlightUseCaseParams params,
  ) {
    return repository.saveMetadataAndGenerateHighlightVariants(
      params.dayId,
      params.currentImagePath,
    );
  }
}

class ChangeHighlightUseCaseParams {
  final String dayId;
  final String currentImagePath;

  const ChangeHighlightUseCaseParams({
    required this.dayId,
    required this.currentImagePath,
  });
}
