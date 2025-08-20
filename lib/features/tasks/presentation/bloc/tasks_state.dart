part of 'tasks_bloc.dart';

abstract class TasksState extends Equatable {
  const TasksState();
  @override
  List<Object> get props => [];
}

class TasksEmptyState extends TasksState {}

class TasksLoadingState extends TasksState {}

class TasksSuccessState extends TasksState {
  final List<TaskEntity> tasks;
  const TasksSuccessState({required this.tasks});
  @override
  List<Object> get props => [tasks];
}

class TasksFailureState extends TasksState {
  final String failure;
  const TasksFailureState(this.failure);
  @override
  List<Object> get props => [failure];
}
