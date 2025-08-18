import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'highlights_state.dart';

class HighlightsCubit extends Cubit<HighlightsState> {
  HighlightsCubit() : super(HighlightsInitial());
}
