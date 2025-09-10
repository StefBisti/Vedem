import 'package:fpdart/fpdart.dart';
import 'package:vedem/core/error/failures.dart';
import 'package:vedem/core/usecase/usecase.dart';
import 'package:vedem/features/highlights/domain/entities/highlight_entity.dart';
import 'package:vedem/features/highlights/domain/repositories/highlights_repository.dart';

class LoadAllHighlightsMetadataUseCase
    implements UseCase<List<HighlightEntity>, NoParams> {
  final HighlightsRepository repository;

  const LoadAllHighlightsMetadataUseCase({required this.repository});

  @override
  Future<Either<Failure, List<HighlightEntity>>> call(NoParams params) {
    return repository.loadAllHighlightsMetadata();
  }
}

class DelayedLoadAllHighlightsMetadataUseCase
    extends LoadAllHighlightsMetadataUseCase {
  final Duration delay = Duration(milliseconds: delayedUseCaseMilliseconds);

  DelayedLoadAllHighlightsMetadataUseCase({required super.repository});

  @override
  Future<Either<Failure, List<HighlightEntity>>> call(NoParams params) async {
    await Future.delayed(delay);
    return super.call(params);
  }
}
