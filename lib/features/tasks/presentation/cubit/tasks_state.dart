part of 'tasks_cubit.dart';

class TasksState extends Equatable {
  final List<TaskEntity> tasks;
  final bool isLoading;
  final String? error;

  const TasksState({this.tasks = const [], this.isLoading = false, this.error});

  TasksState copyWith({
    List<TaskEntity>? tasks,
    bool? isLoading,
    String? error,
  }) {
    return TasksState(
      tasks: tasks ?? this.tasks,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  TaskEntity? getTaskById(int taskId) {
    for (int i = 0; i < tasks.length; i++) {
      if (tasks[i].taskId == taskId) return tasks[i];
    }
    return null;
  }

  @override
  List<Object?> get props => [tasks, isLoading, error];
}
