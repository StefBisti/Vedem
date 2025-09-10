import 'package:fpdart/fpdart.dart';
import 'package:vedem/core/error/failures.dart';
import 'package:vedem/core/usecase/usecase.dart';
import 'package:vedem/features/highlights/domain/entities/highlight_entity.dart';
import 'package:vedem/features/highlights/domain/repositories/highlights_repository.dart';

class LoadMonthHighlightsMetadataUseCase
    implements
        UseCase<
          List<HighlightEntity>,
          LoadMonthHighlightsMetadataUseCaseParams
        > {
  final HighlightsRepository repository;

  const LoadMonthHighlightsMetadataUseCase({required this.repository});

  @override
  Future<Either<Failure, List<HighlightEntity>>> call(
    LoadMonthHighlightsMetadataUseCaseParams params,
  ) {
    return repository.loadMonthHighlightsMetadata(params.monthId);
  }
}

class LoadMonthHighlightsMetadataUseCaseParams {
  final String monthId;

  const LoadMonthHighlightsMetadataUseCaseParams({required this.monthId});
}

class DelayedLoadMonthHighlightsMetadataUseCase
    extends LoadMonthHighlightsMetadataUseCase {
  final Duration delay = Duration(milliseconds: delayedUseCaseMilliseconds);

  DelayedLoadMonthHighlightsMetadataUseCase({required super.repository});

  @override
  Future<Either<Failure, List<HighlightEntity>>> call(
    LoadMonthHighlightsMetadataUseCaseParams params,
  ) async {
    await Future.delayed(delay);
    return super.call(params);
  }
}
