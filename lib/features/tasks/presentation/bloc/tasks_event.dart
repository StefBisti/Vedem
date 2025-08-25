part of 'tasks_bloc.dart';

abstract class TasksEvent extends Equatable {
  const TasksEvent();

  @override
  List<Object> get props => [];
}

class CreateNewTaskEvent extends TasksEvent {
  final String dayId;
  final int categoryId;
  final String content;
  final bool isRecurring;
  final int diamonds;

  const CreateNewTaskEvent({
    required this.dayId,
    required this.categoryId,
    required this.content,
    required this.isRecurring,
    required this.diamonds,
  });

  @override
  List<Object> get props => [
    dayId,
    categoryId,
    content,
    isRecurring,
    diamonds,
  ];
}

class InitializeTasksForDayEvent extends TasksEvent {
  final String dayId;
  const InitializeTasksForDayEvent({required this.dayId});
  @override
  List<Object> get props => [dayId];
}

class ReadTasksForDayEvent extends TasksEvent {
  final String dayId;
  const ReadTasksForDayEvent({required this.dayId});
  @override
  List<Object> get props => [dayId];
}

class ReadTasksForMonthEvent extends TasksEvent {
  final String monthId;
  const ReadTasksForMonthEvent({required this.monthId});
  @override
  List<Object> get props => [monthId];
}

class UpdateTaskEvent extends TasksEvent {
  final int taskId;
  final int newCategoryId;
  final String newContent;
  final bool newIsRecurring;
  final int newDiamonds;

  const UpdateTaskEvent({
    required this.taskId,
    required this.newCategoryId,
    required this.newContent,
    required this.newIsRecurring,
    required this.newDiamonds,
  });

  @override
  List<Object> get props => [
    taskId,
    newCategoryId,
    newContent,
    newIsRecurring,
    newDiamonds,
  ];
}

class DeleteTaskEvent extends TasksEvent {
  final String? dayId;
  final int taskId;

  const DeleteTaskEvent({
    required this.dayId,
    required this.taskId,
  });

  @override
  List<Object> get props => [dayId ?? '', taskId];
}

class SetTaskEvent extends TasksEvent {
  final String dayId;
  final int taskId;
  final bool completed;

  const SetTaskEvent({
    required this.dayId,
    required this.taskId,
    required this.completed,
  });

  @override
  List<Object> get props => [dayId, taskId, completed];
}
