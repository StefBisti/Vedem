import 'package:equatable/equatable.dart';
import 'package:vedem/features/highlights/domain/entities/highlight_entity.dart';

class HighlightModel extends Equatable {
  final String dayId;
  final String headerImagePath;
  final String carouselImagePath;
  final String galleryImagePath;

  const HighlightModel({
    required this.dayId,
    required this.headerImagePath,
    required this.carouselImagePath,
    required this.galleryImagePath,
  });

  HighlightModel copyWith({
    String? dayId,
    String? headerImagePath,
    String? carouselImagePath,
    String? galleryImagePath,
  }) {
    return HighlightModel(
      dayId: dayId ?? this.dayId,
      headerImagePath: headerImagePath ?? this.headerImagePath,
      carouselImagePath: carouselImagePath ?? this.carouselImagePath,
      galleryImagePath: galleryImagePath ?? this.galleryImagePath,
    );
  }

  HighlightEntity toEntity() => HighlightEntity(
    dayId: dayId,
    headerImagePath: headerImagePath,
    carouselImagePath: carouselImagePath,
    galleryImagePath: galleryImagePath,
    exists: headerImagePath != '',
  );

  factory HighlightModel.fromEntity(HighlightEntity e) => HighlightModel(
    dayId: e.dayId,
    headerImagePath: e.headerImagePath ?? '',
    carouselImagePath: e.carouselImagePath ?? '',
    galleryImagePath: e.galleryImagePath ?? '',
  );

  @override
  List<Object?> get props => [
    dayId,
    headerImagePath,
    carouselImagePath,
    galleryImagePath,
  ];
}
