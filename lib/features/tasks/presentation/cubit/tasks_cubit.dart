import 'dart:math';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vedem/core/error/error_messages.dart';
import 'package:vedem/core/utils/time_utils.dart';
import 'package:vedem/features/tasks/domain/entities/subtask_entity.dart';
import 'package:vedem/features/tasks/domain/entities/task_done_type.dart';
import 'package:vedem/features/tasks/domain/entities/task_entity.dart';
import 'package:vedem/features/tasks/domain/entities/task_filter_type.dart';
import 'package:vedem/features/tasks/domain/entities/task_type.dart';
import 'package:vedem/features/tasks/domain/repository/tasks_repository.dart';

part 'tasks_state.dart';

class TasksCubit extends Cubit<TasksState> {
  final TasksRepository _repository;
  final random = Random.secure();

  TasksCubit(this._repository) : super(TasksState());

  Future<void> getTasksForDay(String dayId, bool alsoInitialize) async {
    if (isClosed || state.isLoading) return;

    emit(TasksState(tasks: [], isLoading: true, error: null));
    final res = await _repository.getTasksForDay(dayId, alsoInitialize);
    res.fold(
      (failure) {
        if (isClosed) return;
        emit(TasksState(tasks: [], isLoading: false, error: failure.message));
      },
      (initialTasks) async {
        if (isClosed) return;
        emit(TasksState(tasks: initialTasks, isLoading: false, error: null));
      },
    );
  }

  Future<void> getFilteredTasks(TaskFilterType filterType) async {
    if (state.isLoading || isClosed) return;

    emit(TasksState(tasks: [], isLoading: true, error: null));
    final res = await _repository.getFilteredTasks(filterType);
    res.fold(
      (failure) {
        if (isClosed) return;
        emit(TasksState(tasks: [], isLoading: false, error: failure.message));
      },
      (filteredTasks) async {
        if (isClosed) return;
        emit(TasksState(tasks: filteredTasks, isLoading: false, error: null));
      },
    );
  }

  Future<void> addNewTask({
    required String dayId,
    required int categoryId,
    required String content,
    required List<SubtaskEntity> subtasks,
    required bool isStarred,
    required bool isDailyTask,
    required bool isRewardedTask,
    required int? effortRequired,
    required int? taskImportance,
    required int? timeRequired,
    required int? taskDiamonds,
    required bool isDueTimeActive,
    required int dueTime,
    required bool isNotifyTimeActive,
    required int notifyTime,
  }) async {
    if (isClosed || state.isLoading) return;

    final randomId = -random.nextInt(1 << 32);
    final TaskEntity optimisticTask = TaskEntity(
      taskId: randomId,
      categoryId: categoryId,
      content: content,
      isStarred: isStarred,
      taskType: isDailyTask ? TaskType.repeatDaily : TaskType.plain,
      dayTaskId: randomId,
      taskDoneType: TaskDoneType.notDone,
      subtasks: subtasks,
      taskImportance: isRewardedTask ? taskImportance : null,
      effortRequired: isRewardedTask ? effortRequired : null,
      timeRequired: isRewardedTask ? timeRequired : null,
      onPointDiamonds: isRewardedTask ? taskDiamonds : null,
      notGreatDiamonds: (!isRewardedTask || taskDiamonds == null)
          ? null
          : (taskDiamonds * 0.8).floor(),
      awesomeDiamonds: (!isRewardedTask || taskDiamonds == null)
          ? null
          : (taskDiamonds * 1.2).ceil(),
      dueTimeInMinutes: isDueTimeActive ? dueTime : null,
      notifyTimeInMinutes: isNotifyTimeActive ? notifyTime : null,
    );
    final bool isToday = dayId == TimeUtils.thisDayId;

    if (isToday) {
      final optimisticTasks = TaskEntity.copyList(state.tasks)
        ..add(optimisticTask);
      emit(state.copyWith(tasks: optimisticTasks));
    }

    final res = await _repository.addNewTask(dayId, optimisticTask);
    res.fold(
      (failure) {
        if (isClosed) return;

        final failureTasks = TaskEntity.copyList(state.tasks);
        if (isToday) {
          failureTasks.removeWhere((t) => t.taskId == randomId);
        }
        emit(state.copyWith(tasks: failureTasks, error: failure.message));
      },
      (newTask) {
        if (isClosed) return;

        if (isToday) {
          final successTasks = TaskEntity.copyList(state.tasks);
          final int index = successTasks.indexWhere(
            (t) => t.taskId == randomId,
          );
          successTasks[index] = newTask;
          emit(state.copyWith(tasks: successTasks));
        }
      },
    );
  }

  Future<void> updateTaskForDay({
    required int taskId,
    required int dayTaskId,
    required int categoryId,
    required String content,
    required List<SubtaskEntity> subtasks,
    required bool isStarred,
    required bool isDailyTask,
    required bool isRewardedTask,
    required int? effortRequired,
    required int? taskImportance,
    required int? timeRequired,
    required int? taskDiamonds,
    required bool isDueTimeActive,
    required int dueTime,
    required bool isNotifyTimeActive,
    required int notifyTime,
  }) async {
    if (isClosed || state.isLoading) return;

    final int taskIndex = state.tasks.indexWhere((t) => t.taskId == taskId);
    if (taskIndex == -1) {
      emit(state.copyWith(error: genericError));
      return;
    }
    final TaskEntity previousTask = TaskEntity.copyTask(state.tasks[taskIndex]);
    final TaskEntity newTask = TaskEntity(
      taskId: taskId,
      categoryId: categoryId,
      content: content,
      isStarred: isStarred,
      taskType: previousTask.taskType == TaskType.secondChance
          ? TaskType.secondChance
          : isDailyTask
          ? TaskType.repeatDaily
          : TaskType.plain,
      dayTaskId: dayTaskId,
      taskDoneType: previousTask.taskDoneType,
      subtasks: subtasks,
      taskImportance: isRewardedTask ? taskImportance : null,
      effortRequired: isRewardedTask ? effortRequired : null,
      timeRequired: isRewardedTask ? timeRequired : null,
      onPointDiamonds: isRewardedTask ? taskDiamonds : null,
      notGreatDiamonds: (!isRewardedTask || taskDiamonds == null)
          ? null
          : (taskDiamonds * 0.8).floor(),
      awesomeDiamonds: (!isRewardedTask || taskDiamonds == null)
          ? null
          : (taskDiamonds * 1.2).ceil(),
      dueTimeInMinutes: isDueTimeActive ? dueTime : null,
      notifyTimeInMinutes: isNotifyTimeActive ? notifyTime : null,
    );

    final optimisticTasks = TaskEntity.copyList(state.tasks);
    optimisticTasks[taskIndex] = newTask;
    emit(state.copyWith(tasks: optimisticTasks));

    final res = await _repository.updateTaskForDay(newTask);
    res.fold((failure) {
      if (isClosed) return;
      final failureTasks = TaskEntity.copyList(state.tasks);
      failureTasks[taskIndex] = previousTask;
      emit(state.copyWith(tasks: failureTasks, error: failure.message));
    }, (_) {});
  }

  Future<void> updateTask({
    required int taskId,
    required int categoryId,
    required String content,
    required bool isStarred,
    required bool isDailyTask,
  }) async {
    if (isClosed || state.isLoading) return;

    final int taskIndex = state.tasks.indexWhere((t) => t.taskId == taskId);
    if (taskIndex == -1) {
      emit(state.copyWith(error: genericError));
      return;
    }
    final TaskEntity previousTask = TaskEntity.copyTask(state.tasks[taskIndex]);
    final TaskEntity newTask = TaskEntity(
      taskId: taskId,
      categoryId: categoryId,
      content: content,
      isStarred: isStarred,
      taskType: isDailyTask ? TaskType.repeatDaily : TaskType.plain,
    );

    final optimisticTasks = TaskEntity.copyList(state.tasks);
    optimisticTasks[taskIndex] = newTask;
    emit(state.copyWith(tasks: optimisticTasks));

    final res = await _repository.updateTask(newTask);
    res.fold((failure) {
      if (isClosed) return;
      final failureTasks = TaskEntity.copyList(state.tasks);
      failureTasks[taskIndex] = previousTask;
      emit(state.copyWith(tasks: failureTasks, error: failure.message));
    }, (_) {});
  }

  Future<void> deleteTaskForDay(int dayTaskId) async {
    if (isClosed || state.isLoading) return;

    final int taskIndex = state.tasks.indexWhere(
      (t) => t.dayTaskId == dayTaskId,
    );
    if (taskIndex == -1) {
      emit(state.copyWith(error: genericError));
      return;
    }
    final TaskEntity deletedTask = TaskEntity.copyTask(state.tasks[taskIndex]);
    final optimisticTasks = TaskEntity.copyList(state.tasks);
    optimisticTasks.removeAt(taskIndex);
    emit(state.copyWith(tasks: optimisticTasks));

    final res = await _repository.deleteTaskForDay(dayTaskId);
    res.fold((failure) {
      if (isClosed) return;
      final failureTasks = TaskEntity.copyList(state.tasks);
      failureTasks.insert(taskIndex, deletedTask);
      emit(state.copyWith(tasks: failureTasks, error: failure.message));
    }, (_) {});
  }

  Future<void> deleteTask(int taskId) async {
    if (isClosed || state.isLoading) return;

    final int taskIndex = state.tasks.indexWhere((t) => t.taskId == taskId);
    if (taskIndex == -1) {
      emit(state.copyWith(error: genericError));
      return;
    }
    final TaskEntity deletedTask = TaskEntity.copyTask(state.tasks[taskIndex]);
    final optimisticTasks = TaskEntity.copyList(state.tasks);
    optimisticTasks.removeAt(taskIndex);
    emit(state.copyWith(tasks: optimisticTasks));

    final res = await _repository.deleteTask(taskId);
    res.fold((failure) {
      if (isClosed) return;
      final failureTasks = TaskEntity.copyList(state.tasks);
      failureTasks.insert(taskIndex, deletedTask);
      emit(state.copyWith(tasks: failureTasks, error: failure.message));
    }, (_) {});
  }

  Future<void> toggleTask(int dayTaskId, TaskDoneType doneType) async {
    if (isClosed || state.isLoading) return;

    final int taskIndex = state.tasks.indexWhere(
      (t) => t.dayTaskId == dayTaskId,
    );
    if (taskIndex == -1) {
      emit(state.copyWith(error: genericError));
      return;
    }

    final previousTask = TaskEntity.copyTask(state.tasks[taskIndex]);
    final optimisticTasks = TaskEntity.copyList(state.tasks);
    optimisticTasks[taskIndex] = optimisticTasks[taskIndex].copyWith(
      taskDoneType: doneType,
      subtasks: optimisticTasks[taskIndex].subtasks
          .map((s) => SubtaskEntity(content: s.content, completed: true))
          .toList(),
    );
    emit(state.copyWith(tasks: optimisticTasks));

    final res = await _repository.toggleTask(dayTaskId, doneType);
    res.fold((failure) {
      if (isClosed) return;
      final failureTasks = TaskEntity.copyList(state.tasks);
      failureTasks[taskIndex] = previousTask;
      emit(state.copyWith(tasks: failureTasks, error: failure.message));
    }, (_) {});
  }

  Future<void> toggleSubtask(
    int dayTaskId,
    int subtaskIndex,
    bool completed,
  ) async {
    if (isClosed || state.isLoading) return;

    final int taskIndex = state.tasks.indexWhere(
      (t) => t.dayTaskId == dayTaskId,
    );
    if (taskIndex == -1) {
      emit(state.copyWith(error: genericError));
      return;
    }
    final previousCompleted =
        state.tasks[taskIndex].subtasks[subtaskIndex].completed;
    final optimisticTasks = TaskEntity.copyList(state.tasks);
    SubtaskEntity newSubtask = optimisticTasks[taskIndex].subtasks[subtaskIndex]
        .copyWith(completed: completed);
    optimisticTasks[taskIndex].subtasks[subtaskIndex] = newSubtask;
    emit(state.copyWith(tasks: optimisticTasks));

    final res = await _repository.toggleSubtask(
      state.tasks[taskIndex],
      subtaskIndex,
      completed,
    );
    res.fold((failure) {
      if (isClosed) return;
      final failureTasks = TaskEntity.copyList(state.tasks);
      SubtaskEntity previousSubtask = failureTasks[taskIndex]
          .subtasks[subtaskIndex]
          .copyWith(completed: previousCompleted);
      failureTasks[taskIndex].subtasks[subtaskIndex] = previousSubtask;
      emit(state.copyWith(tasks: failureTasks, error: failure.message));
    }, (_) {});
  }
}
