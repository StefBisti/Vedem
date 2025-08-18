import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'days_state.dart';

class DaysCubit extends Cubit<DaysState> {
  DaysCubit() : super(DaysInitial());
}
