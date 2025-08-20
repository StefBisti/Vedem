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

class InitializeTasksForDay extends TasksEvent {
  final String dayId;
  const InitializeTasksForDay({required this.dayId});
  @override
  List<Object> get props => [dayId];
}

class ReadTasksForDayEvent extends TasksEvent {
  final String dayId;
  const ReadTasksForDayEvent({required this.dayId});
  @override
  List<Object> get props => [dayId];
}

class UpdateTaskEvent extends TasksEvent {
  final int taskId;
  final int newCategoryId;
  final String newContent;
  final bool newIsRecurring;
  final int newDiamonds;
  final int previousDiamonds;

  const UpdateTaskEvent({
    required this.taskId,
    required this.newCategoryId,
    required this.newContent,
    required this.newIsRecurring,
    required this.newDiamonds,
    required this.previousDiamonds,
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
  final bool isRecurring;

  const DeleteTaskEvent({
    required this.dayId,
    required this.taskId,
    required this.isRecurring,
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
