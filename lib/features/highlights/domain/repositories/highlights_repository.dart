import 'package:fpdart/fpdart.dart';
import 'package:vedem/core/error/failures.dart';
import 'package:vedem/features/highlights/domain/entities/highlight_cache_quality.dart';
import 'package:vedem/features/highlights/domain/entities/highlight_entity.dart';

abstract interface class HighlightsRepository {
  Future<Either<Failure, List<HighlightEntity>>> loadAllHighlightsMetadata();
  Future<Either<Failure, List<HighlightEntity>>> loadMonthHighlightsMetadata(
    String monthId,
  );
  Future<Either<Failure, HighlightEntity>> saveMetadataAndGenerateHighlightVariants(
    String dayId,
    String currentImagePath,
  );
  Future<Either<Failure, Unit>> deleteHighlight(String dayId);

  Future<Either<Failure, List<HighlightEntity>>> cacheHighlights(
    List<HighlightEntity> uncachedHighlights,
    List<int> indices,
    HighlightCacheQuality quality,
    bool uncacheEverythingElse,
  );
}
