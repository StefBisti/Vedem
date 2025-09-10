import 'package:fpdart/fpdart.dart';
import 'package:vedem/core/error/failures.dart';
import 'package:vedem/core/usecase/usecase.dart';
import 'package:vedem/features/highlights/domain/entities/highlight_cache_quality.dart';
import 'package:vedem/features/highlights/domain/entities/highlight_entity.dart';
import 'package:vedem/features/highlights/domain/repositories/highlights_repository.dart';

class CacheHighlightsUseCase
    implements UseCase<List<HighlightEntity>, CacheHighlightsUseCaseParams> {
  final HighlightsRepository repository;

  const CacheHighlightsUseCase({required this.repository});
  @override
  Future<Either<Failure, List<HighlightEntity>>> call(
    CacheHighlightsUseCaseParams params,
  ) {
    return repository.cacheHighlights(
      params.uncachedHighlights,
      params.indicesToCache,
      params.cacheQuality,
      params.uncacheEverythingElse,
    );
  }
}

class CacheHighlightsUseCaseParams {
  final List<HighlightEntity> uncachedHighlights;
  final List<int> indicesToCache;
  final HighlightCacheQuality cacheQuality;
  final bool uncacheEverythingElse;

  CacheHighlightsUseCaseParams({
    required this.uncachedHighlights,
    required this.indicesToCache,
    required this.cacheQuality,
    this.uncacheEverythingElse = false,
  });
}

class DelayedCacheHighlightsUseCase extends CacheHighlightsUseCase {
  final Duration delay = Duration(milliseconds: delayedUseCaseMilliseconds);

  DelayedCacheHighlightsUseCase({required super.repository});

  @override
  Future<Either<Failure, List<HighlightEntity>>> call(
    CacheHighlightsUseCaseParams params,
  ) async {
    await Future.delayed(delay);
    return super.call(params);
  }
}
