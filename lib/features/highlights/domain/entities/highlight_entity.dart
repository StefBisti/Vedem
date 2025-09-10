import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import 'package:vedem/features/highlights/domain/entities/highlight_cache_quality.dart';

class HighlightEntity extends Equatable {
  final String dayId;
  final String? headerImagePath;
  final String? carouselImagePath;
  final String? galleryImagePath;
  final bool exists;
  final Uint8List? cachedImage;
  final HighlightCacheQuality cacheQuality;

  const HighlightEntity({
    required this.dayId,
    this.headerImagePath,
    this.carouselImagePath,
    this.galleryImagePath,
    this.exists = false,
    this.cachedImage,
    this.cacheQuality = HighlightCacheQuality.none,
  });

  HighlightEntity copyWith({
    String? dayId,
    String? headerImagePath,
    String? carouselImagePath,
    String? galleryImagePath,
    bool? exists,
    Uint8List? cachedImage,
    HighlightCacheQuality? cacheQuality,
  }) {
    return HighlightEntity(
      dayId: dayId ?? this.dayId,
      headerImagePath: headerImagePath ?? this.headerImagePath,
      carouselImagePath: carouselImagePath ?? this.carouselImagePath,
      galleryImagePath: galleryImagePath ?? this.galleryImagePath,
      exists: exists ?? this.exists,
      cachedImage: cachedImage ?? this.cachedImage,
      cacheQuality: cacheQuality ?? this.cacheQuality,
    );
  }

  String getCachePath(HighlightCacheQuality quality) {
    String path;
    if (quality == HighlightCacheQuality.headerHigh) {
      path = headerImagePath!;
    } else if (quality == HighlightCacheQuality.carouselMedium) {
      path = carouselImagePath!;
    } else {
      path = galleryImagePath!;
    }
    return path;
  }

  @override
  List<Object?> get props => [
    dayId,
    headerImagePath,
    carouselImagePath,
    galleryImagePath,
    exists,
    cachedImage,
    cacheQuality,
  ];
}
