part of 'rich_inputs_cubit.dart';

class RichInputsState extends Equatable {
  final RichInputEntity richInput;
  final bool isLoading;
  final String? error;

  const RichInputsState({
    this.richInput = const RichInputEntity(parts: []),
    this.isLoading = false,
    this.error,
  });

  RichInputsState copyWith({
    RichInputEntity? richInput,
    bool? isLoading,
    String? error,
  }) {
    return RichInputsState(
      richInput: richInput ?? this.richInput,
      isLoading: isLoading ?? this.isLoading,
      error: error, 
    );
  }

  @override
  List<Object> get props => [];
}
