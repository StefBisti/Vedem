import 'dart:typed_data';

import 'package:fpdart/fpdart.dart';
import 'package:vedem/features/highlights/data/models/highlight_model.dart';

abstract interface class HighlightsDataSource {
  Future<List<HighlightModel>> readAllHighlightsMetadata();

  Future<List<HighlightModel>> readMonthHighlightsMetadata(String monthId);

  Future<Unit> writeHighlightMetadataForDay(
    HighlightModel highlight,
    String dayId,
  );

  Future<Unit> deleteHighlightMetadataForDay(String dayId);

  Future<Unit> generateVariantsForHighlight(
    String currentImagePath,
    String headerImagePath,
    String carouselImagePath,
    String galleryImagePath,
  );
  Future<Uint8List> getVariantForHighlight(String path);
  Future<Unit> deleteVariantsForHighlight(
    String headerImagePath,
    String carouselImagePath,
    String galleryImagePath,
  );
}
