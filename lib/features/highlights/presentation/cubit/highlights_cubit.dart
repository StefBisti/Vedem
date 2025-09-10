import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vedem/core/error/error_messages.dart';
import 'package:vedem/core/usecase/usecase.dart';
import 'package:vedem/features/highlights/domain/entities/highlight_cache_quality.dart';
import 'package:vedem/features/highlights/domain/entities/highlight_entity.dart';
import 'package:vedem/features/highlights/domain/usecases/cache_highlights_use_case.dart';
import 'package:vedem/features/highlights/domain/usecases/change_highlight_use_case.dart';
import 'package:vedem/features/highlights/domain/usecases/delete_highlight_use_case.dart';
import 'package:vedem/features/highlights/domain/usecases/load_all_highlights_metadata_use_case.dart';
import 'package:vedem/features/highlights/domain/usecases/load_month_highlights_metadata_use_case.dart';

part 'highlights_state.dart';

class HighlightsCubit extends Cubit<HighlightsState> {
  final LoadAllHighlightsMetadataUseCase _loadAllHighlightsMetadataUseCase;
  final LoadMonthHighlightsMetadataUseCase _loadMonthHighlightsMetadataUseCase;
  final CacheHighlightsUseCase _cacheHighlightsUseCase;
  final ChangeHighlightUseCase _changeHighlightUseCase;
  final DeleteHighlightUseCase _deleteHighlightUseCase;

  HighlightsCubit(
    this._loadAllHighlightsMetadataUseCase,
    this._loadMonthHighlightsMetadataUseCase,
    this._cacheHighlightsUseCase,
    this._changeHighlightUseCase,
    this._deleteHighlightUseCase,
  ) : super(HighlightsState());

  Future<void> loadHighlightsForGallery() async {
    if (isClosed) return;
    if (state.isLoading) {
      emit(state.copyWith(error: noOperationWhileIsLoadingError));
      return;
    }
    emit(state.copyWith(isLoading: true, error: null));

    final res = await _loadAllHighlightsMetadataUseCase.call(NoParams());
    res.fold(
      (failure) {
        if (!isClosed) {
          emit(state.copyWith(isLoading: false, error: failure.message));
        }
      },
      (highlightsMetadata) async {
        if (!isClosed) {
          emit(
            HighlightsState(
              highlights: highlightsMetadata,
              isLoading: false,
              error: null,
            ),
          );
          final res = await _cacheHighlightsUseCase.call(
            CacheHighlightsUseCaseParams(
              uncachedHighlights: highlightsMetadata,
              indicesToCache: List.generate(
                highlightsMetadata.length,
                (i) => i,
              ),
              cacheQuality: HighlightCacheQuality.galleryLow,
            ),
          );
          res.fold(
            (failure) {
              if (!isClosed) {
                emit(state.copyWith(isLoading: false, error: failure.message));
              }
            },
            (cachedHighlights) {
              if (!isClosed) {
                emit(
                  HighlightsState(
                    highlights: cachedHighlights,
                    isLoading: false,
                    error: null,
                  ),
                );
              }
            },
          );
        }
      },
    );
  }

  Future<void> loadHighlightsForMonth(String monthId) async {
    if (isClosed) return;
    if (state.isLoading) {
      emit(state.copyWith(error: noOperationWhileIsLoadingError));
      return;
    }
    emit(state.copyWith(isLoading: true, error: null));

    final res = await _loadMonthHighlightsMetadataUseCase.call(
      LoadMonthHighlightsMetadataUseCaseParams(monthId: monthId),
    );
    res.fold(
      (failure) {
        if (!isClosed) {
          emit(state.copyWith(isLoading: false, error: failure.message));
        }
      },
      (highlightsMetadata) async {
        if (!isClosed) {
          emit(
            HighlightsState(
              highlights: highlightsMetadata,
              isLoading: false,
              error: null,
            ),
          );
          final res = await _cacheHighlightsUseCase.call(
            CacheHighlightsUseCaseParams(
              uncachedHighlights: highlightsMetadata,
              indicesToCache: _getTwoApartFromIndex(
                highlightsMetadata,
                highlightsMetadata.length - 1,
              ),
              cacheQuality: HighlightCacheQuality.carouselMedium,
              uncacheEverythingElse: true,
            ),
          );
          res.fold(
            (failure) {
              if (!isClosed) {
                emit(state.copyWith(isLoading: false, error: failure.message));
              }
            },
            (cachedHighlights) {
              if (!isClosed) {
                emit(
                  HighlightsState(
                    highlights: cachedHighlights,
                    isLoading: false,
                    error: null,
                  ),
                );
              }
            },
          );
        }
      },
    );
  }

  Future<void> handleNewCarouselHighlightInFocus(int highlightIndex) async {
    if (isClosed || state.isLoading) return;
    final res = await _cacheHighlightsUseCase.call(
      CacheHighlightsUseCaseParams(
        uncachedHighlights: state.highlights,
        indicesToCache: _getTwoApartFromIndex(state.highlights, highlightIndex),
        cacheQuality: HighlightCacheQuality.carouselMedium,
        uncacheEverythingElse: true,
      ),
    );
    res.fold(
      (failure) {
        if (!isClosed) {
          emit(state.copyWith(isLoading: false, error: failure.message));
        }
      },
      (newCachedHighlights) {
        if (!isClosed) {
          emit(
            HighlightsState(
              highlights: newCachedHighlights,
              isLoading: false,
              error: null,
            ),
          );
        }
      },
    );
  }

  Future<void> handleSelectedHighlightForDay(int highlightIndex) async {
    if (isClosed || state.isLoading) return;
    final res = await _cacheHighlightsUseCase.call(
      CacheHighlightsUseCaseParams(
        uncachedHighlights: state.highlights,
        indicesToCache: [highlightIndex],
        cacheQuality: HighlightCacheQuality.headerHigh,
        uncacheEverythingElse: false,
      ),
    );
    res.fold(
      (failure) {
        if (!isClosed) {
          emit(state.copyWith(isLoading: false, error: failure.message));
        }
      },
      (cachedHighlights) {
        if (!isClosed) {
          emit(
            HighlightsState(
              highlights: cachedHighlights,
              isLoading: false,
              error: null,
            ),
          );
        }
      },
    );
  }

  Future<void> handleUnselectedHighlightForDay(int highlightIndex) async {
    if (isClosed || state.isLoading) return;
    final res = await _cacheHighlightsUseCase.call(
      CacheHighlightsUseCaseParams(
        uncachedHighlights: state.highlights,
        indicesToCache: [highlightIndex],
        cacheQuality: HighlightCacheQuality.carouselMedium,
        uncacheEverythingElse: false,
      ),
    );
    res.fold(
      (failure) {
        if (!isClosed) {
          emit(state.copyWith(isLoading: false, error: failure.message));
        }
      },
      (cachedHighlights) {
        if (!isClosed) {
          emit(
            HighlightsState(
              highlights: cachedHighlights,
              isLoading: false,
              error: null,
            ),
          );
        }
      },
    );
  }

  Future<void> changeHighlight(
    int highlightIndex,
    ImageSource imageSource,
  ) async {
    if (isClosed || state.isLoading) return;

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: imageSource);

    if (pickedFile == null) return;

    final List<HighlightEntity> newHighlights = List.from(state.highlights);
    newHighlights[highlightIndex] = newHighlights[highlightIndex].copyWith(
      exists: true,
      cacheQuality: HighlightCacheQuality.none,
      cachedImage: Uint8List(0),
    );
    emit(state.copyWith(highlights: newHighlights));

    final res = await _changeHighlightUseCase.call(
      ChangeHighlightUseCaseParams(
        currentImagePath: pickedFile.path,
        dayId: state.highlights[highlightIndex].dayId,
      ),
    );
    res.fold(
      (failure) {
        if (!isClosed) {
          emit(state.copyWith(isLoading: false, error: failure.message));
        }
      },
      (newHighlight) async {
        if (!isClosed) {
          List<HighlightEntity> newHighlights = List.from(state.highlights);
          newHighlights[highlightIndex] = newHighlight;
          emit(
            HighlightsState(
              highlights: newHighlights,
              isLoading: false,
              error: null,
            ),
          );

          final res = await _cacheHighlightsUseCase.call(
            CacheHighlightsUseCaseParams(
              uncachedHighlights: newHighlights,
              indicesToCache: [highlightIndex],
              cacheQuality: HighlightCacheQuality.headerHigh,
            ),
          );
          res.fold(
            (failure) {
              if (!isClosed) {
                emit(state.copyWith(isLoading: false, error: failure.message));
              }
            },
            (newHighlights) {
              if (!isClosed) {
                emit(
                  HighlightsState(
                    highlights: newHighlights,
                    isLoading: false,
                    error: null,
                  ),
                );
              }
            },
          );
        }
      },
    );
  }

  Future<void> deleteHighlight(int highlightIndex) async {
    if (isClosed || state.isLoading) return;

    final List<HighlightEntity> newHighlights = List.from(state.highlights);
    newHighlights[highlightIndex] = newHighlights[highlightIndex].copyWith(
      exists: false,
      cacheQuality: HighlightCacheQuality.none,
      cachedImage: null,
    );
    emit(state.copyWith(highlights: newHighlights));

    final res = await _deleteHighlightUseCase.call(
      DeleteHighlightUseCaseParams(
        dayId: state.highlights[highlightIndex].dayId,
      ),
    );
    res.fold(
      (failure) {
        if (!isClosed) {
          emit(state.copyWith(isLoading: false, error: failure.message));
        }
      },
      (unit) {
        if (!isClosed) {
          emit(state.copyWith(isLoading: false, error: null));
        }
      },
    );
  }

  List<int> _getTwoApartFromIndex(List<HighlightEntity> highlights, int index) {
    final List<int> result = [];
    final int count = highlights.length;
    final indices = [index - 2, index - 1, index, index + 1, index + 2];
    for (int i in indices) {
      if (i >= 0 && i < count) {
        result.add(i);
      }
    }
    return result;
  }
}
