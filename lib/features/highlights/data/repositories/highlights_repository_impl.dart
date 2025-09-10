import 'dart:typed_data';

import 'package:fpdart/fpdart.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vedem/core/error/exceptions.dart';
import 'package:vedem/core/error/failures.dart';
import 'package:vedem/core/utils/time_utils.dart';
import 'package:vedem/features/highlights/data/datasources/highlights_data_source.dart';
import 'package:vedem/features/highlights/data/models/highlight_model.dart';
import 'package:vedem/features/highlights/domain/entities/highlight_cache_quality.dart';
import 'package:vedem/features/highlights/domain/entities/highlight_entity.dart';
import 'package:vedem/features/highlights/domain/repositories/highlights_repository.dart';

class HighlightsRepositoryImpl implements HighlightsRepository {
  final HighlightsDataSource dataSource;

  const HighlightsRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, List<HighlightEntity>>>
  loadAllHighlightsMetadata() async {
    try {
      List<HighlightModel> highlights = await dataSource
          .readAllHighlightsMetadata();
      return right(highlights.map((m) => m.toEntity()).toList());
    } on LocalHiveException catch (e) {
      return left(LocalHiveFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<HighlightEntity>>> loadMonthHighlightsMetadata(
    String monthId,
  ) async {
    try {
      List<HighlightModel> highlights = await dataSource
          .readMonthHighlightsMetadata(monthId);

      List<HighlightEntity> highlightEntities = highlights
          .map((m) => m.toEntity())
          .toList();

      if (monthId == TimeUtils.thisMonthId &&
          highlights.all((m) => m.dayId != TimeUtils.thisDayId)) {
        HighlightEntity newEntity = HighlightEntity(dayId: TimeUtils.thisDayId);
        highlightEntities.add(newEntity);
        dataSource.writeHighlightMetadataForDay(
          // not awaited, running in the background
          HighlightModel.fromEntity(newEntity),
          TimeUtils.thisDayId,
        );
      }
      return right(highlightEntities);
    } on LocalHiveException catch (e) {
      return left(LocalHiveFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, HighlightEntity>>
  saveMetadataAndGenerateHighlightVariants(
    String dayId,
    String currentImagePath,
  ) async {
    try {
      final String appDirPath = (await getApplicationDocumentsDirectory()).path;
      String headerImagePath = '$appDirPath/${dayId}_header';
      String carouselImagePath = '$appDirPath/${dayId}_carousel';
      String galleryImagePath = '$appDirPath/${dayId}_gallery';

      HighlightModel model = HighlightModel(
        dayId: dayId,
        headerImagePath: headerImagePath,
        carouselImagePath: carouselImagePath,
        galleryImagePath: galleryImagePath,
      );

      await Future.wait([
        dataSource.generateVariantsForHighlight(
          currentImagePath,
          headerImagePath,
          carouselImagePath,
          galleryImagePath,
        ),
        dataSource.writeHighlightMetadataForDay(model, dayId),
      ]);

      return right(model.toEntity());
    } on LocalHiveException catch (e) {
      return left(LocalHiveFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteHighlight(String dayId) async {
    try {
      dataSource.deleteHighlightMetadataForDay(dayId);
      return right(unit);
    } on LocalHiveException catch (e) {
      return left(LocalHiveFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<HighlightEntity>>> cacheHighlights(
    List<HighlightEntity> uncachedHighlights,
    List<int> indices,
    HighlightCacheQuality quality,
    bool uncacheEverythingElse,
  ) async {
    try {
      List<HighlightEntity> newHighlights = List.from(uncachedHighlights);

      for (int i in indices) {
        if (newHighlights[i].exists == false) continue;

        if (quality == HighlightCacheQuality.none) {
          newHighlights[i] = newHighlights[i].copyWith(
            cacheQuality: HighlightCacheQuality.none,
            cachedImage: Uint8List(0),
          );
        } else if (quality != newHighlights[i].cacheQuality) {
          String path = newHighlights[i].getCachePath(quality);
          Uint8List cachedImage = await dataSource.getVariantForHighlight(path);
          newHighlights[i] = newHighlights[i].copyWith(
            cacheQuality: quality,
            cachedImage: cachedImage,
          );
        }
      }
      if (uncacheEverythingElse) {
        for (int i = 0; i < newHighlights.length; i++) {
          if (indices.contains(i) == false) {
            newHighlights[i] = newHighlights[i].copyWith(
              cacheQuality: HighlightCacheQuality.none,
              cachedImage: Uint8List(0),
            );
          }
        }
      }
      return right(newHighlights);
    } on ImageProcessingException catch (e) {
      return left(HighlightProcessingFailure(e.message));
    }
  }
}
