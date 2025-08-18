import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'highlights_state.dart';

class HighlightsCubit extends Cubit<HighlightsState> {
  HighlightsCubit() : super(HighlightsInitial());
}
