part of 'highlights_cubit.dart';

class HighlightsState extends Equatable {
  final List<HighlightEntity> highlights;
  final bool isLoading;
  final String? error;

  const HighlightsState({
    this.highlights = const [],
    this.isLoading = false,
    this.error,
  });

  HighlightsState copyWith({
    List<HighlightEntity>? highlights,
    bool? isLoading,
    String? error,
    int? stateVersion,
  }) {
    return HighlightsState(
      highlights: highlights ?? this.highlights,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List<Object> get props => [highlights, isLoading, error ?? ''];
}
