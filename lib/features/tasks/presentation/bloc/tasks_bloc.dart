import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vedem/features/tasks/domain/entities/task_entity.dart';
import 'package:vedem/features/tasks/domain/usecases/create_new_task_use_case.dart';
import 'package:vedem/features/tasks/domain/usecases/delete_task_usecase.dart';
import 'package:vedem/features/tasks/domain/usecases/initialize_tasks_for_day_use_case.dart';
import 'package:vedem/features/tasks/domain/usecases/read_tasks_for_day_usecase.dart';
import 'package:vedem/features/tasks/domain/usecases/set_task_usecase.dart';
import 'package:vedem/features/tasks/domain/usecases/update_task_usecase.dart';

part 'tasks_event.dart';
part 'tasks_state.dart';

class TasksBloc extends Bloc<TasksEvent, TasksState> {
  final CreateNewTaskUseCase createNewTaskUseCase;
  final InitializeTasksForDayUseCase initializeTasksForDayUseCase;
  final ReadTasksForDayUseCase readTasksForDayUseCase;
  final UpdateTaskUseCase updateTaskUseCase;
  final DeleteTaskUseCase deleteTaskUseCase;
  final SetTaskUseCase setTaskUseCase;

  TasksBloc({
    required this.createNewTaskUseCase,
    required this.initializeTasksForDayUseCase,
    required this.readTasksForDayUseCase,
    required this.updateTaskUseCase,
    required this.deleteTaskUseCase,
    required this.setTaskUseCase,
  }) : super(TasksInitialState()) {
    on<CreateNewTaskEvent>(_onCreateNewTaskEvent);
    on<InitializeTasksForDay>(_onInitializeTasksForDayEvent);
    on<ReadTasksForDayEvent>(_onReadTasksForDayEvent);
    on<UpdateTaskEvent>(_onUpdateTaskEvent);
    on<DeleteTaskEvent>(_onDeleteTaskEvent);
    on<SetTaskEvent>(_onSetTaskEvent);
  }

  void _onCreateNewTaskEvent(
    CreateNewTaskEvent event,
    Emitter<TasksState> emit,
  ) async {
    if (state is! TasksSuccessState) {
      emit(TasksFailureState('Tried to add task in an invalid app state'));
      return;
    }

    final int tempId = -DateTime.now().microsecondsSinceEpoch;
    final tempTask = TaskEntity(
      taskId: tempId,
      categoryId: event.categoryId,
      content: event.content,
      isRecurring: event.isRecurring,
      diamonds: event.diamonds,
      isDone: false,
    );

    final optimisticTasks = List<TaskEntity>.from(
      (state as TasksSuccessState).tasks,
    )..add(tempTask);
    emit(TasksSuccessState(tasks: optimisticTasks));

    final res = await createNewTaskUseCase.call(
      CreateNewTaskUseCaseParams(
        dayId: event.dayId,
        categoryId: event.categoryId,
        content: event.content,
        isRecurring: event.isRecurring,
        diamonds: event.diamonds,
      ),
    );
    res.fold(
      (failure) {
        if (state is TasksSuccessState &&
            (state as TasksSuccessState).tasks.any((t) => t.taskId == tempId)) {
          final afterFailure = (state as TasksSuccessState).tasks
              .where((t) => t.taskId != tempId)
              .toList();
          emit(TasksSuccessState(tasks: afterFailure));
        }
        emit(TasksFailureState(failure.message));
      },
      (createdTask) {
        if (state is TasksSuccessState &&
            (state as TasksSuccessState).tasks.any((t) => t.taskId == tempId)) {
          final currentTasks = (state as TasksSuccessState).tasks;
          final replaced = currentTasks
              .map((t) => t.taskId == tempId ? createdTask : t)
              .toList();
          emit(TasksSuccessState(tasks: replaced));
        }
      },
    );
  }

  void _onInitializeTasksForDayEvent(
    InitializeTasksForDay event,
    Emitter<TasksState> emit,
  ) async {
    emit(TasksLoadingState());
    final res = await initializeTasksForDayUseCase.call(
      InitializeTasksForDayUseCaseParams(dayId: event.dayId),
    );
    res.fold(
      (failure) => emit(TasksFailureState(failure.message)),
      (initialTasks) => emit(TasksSuccessState(tasks: initialTasks)),
    );
  }

  void _onReadTasksForDayEvent(
    ReadTasksForDayEvent event,
    Emitter<TasksState> emit,
  ) async {
    emit(TasksLoadingState());
    final res = await readTasksForDayUseCase.call(
      ReadTasksForDayUseCaseParams(dayId: event.dayId),
    );
    res.fold(
      (failure) => emit(TasksFailureState(failure.message)),
      (tasks) => emit(TasksSuccessState(tasks: tasks)),
    );
  }

  void _onUpdateTaskEvent(
    UpdateTaskEvent event,
    Emitter<TasksState> emit,
  ) async {
    if (state is! TasksSuccessState) {
      emit(TasksFailureState('Tried to update a task in an invalid app state'));
      return;
    }
    final currentState = state as TasksSuccessState;
    final optimisticTasks = List<TaskEntity>.from(currentState.tasks);

    late TaskEntity previousTask;
    late TaskEntity newTask;
    for (int i = 0; i < optimisticTasks.length; i++) {
      if (optimisticTasks[i].taskId == event.taskId) {
        previousTask = optimisticTasks[i];
        newTask = TaskEntity(
          taskId: event.taskId,
          categoryId: event.newCategoryId,
          content: event.newContent,
          isRecurring: event.newIsRecurring,
          diamonds: event.newDiamonds,
          isDone: optimisticTasks[i].isDone,
        );
        optimisticTasks[i] = newTask;
        break;
      }
    }
    emit(TasksSuccessState(tasks: optimisticTasks));

    final res = await updateTaskUseCase.call(
      UpdateTaskUseCaseParams(
        taskId: event.taskId,
        categoryId: event.newCategoryId,
        content: event.newContent,
        isRecurring: event.newIsRecurring,
        diamonds: event.newDiamonds,
      ),
    );
    res.fold((failure) {
      if (state is TasksSuccessState) {
        final afterFailure = (state as TasksSuccessState).tasks;
        for (int i = 0; i < afterFailure.length; i++) {
          if (afterFailure[i].taskId == previousTask.taskId) {
            afterFailure[i] = previousTask;
            break;
          }
        }
        emit(TasksSuccessState(tasks: afterFailure));
      }
      emit(TasksFailureState(failure.message));
    }, (unit) {});
  }

  void _onDeleteTaskEvent(
    DeleteTaskEvent event,
    Emitter<TasksState> emit,
  ) async {
    if (state is! TasksSuccessState) {
      emit(TasksFailureState('Tried to delete a task in an invalid app state'));
      return;
    }
    final optimisticTasks = List<TaskEntity>.from(
      (state as TasksSuccessState).tasks,
    );
    late TaskEntity? deletedTask;
    late int? deletedIndex;
    for (int i = 0; i < optimisticTasks.length; i++) {
      if (optimisticTasks[i].taskId == event.taskId) {
        deletedTask = optimisticTasks[i];
        deletedIndex = i;
        break;
      }
    }
    if (deletedTask == null) {
      emit(TasksFailureState('Tried to delete a task that does not exist'));
      return;
    }
    optimisticTasks.removeAt(deletedIndex!);
    emit(TasksSuccessState(tasks: optimisticTasks));

    final currentState = state;
    final res = await deleteTaskUseCase.call(
      DeleteTaskUseCaseParams(
        dayId: event.dayId,
        taskId: event.taskId,
        isRecurring: event.isRecurring,
      ),
    );
    res.fold((failure) {
      if (state == currentState) {
        // state has not changed
        final afterFailure = List<TaskEntity>.from(
          (state as TasksSuccessState).tasks,
        );
        afterFailure.insert(deletedIndex!, deletedTask!);
        emit(TasksSuccessState(tasks: afterFailure));
      }
      emit(TasksFailureState(failure.message));
    }, (unit) {});
  }

  void _onSetTaskEvent(SetTaskEvent event, Emitter<TasksState> emit) async {
    if (state is! TasksSuccessState) {
      emit(TasksFailureState('Tried to set a task in an invalid app state'));
      return;
    }
    final optimisticTasks = List<TaskEntity>.from(
      (state as TasksSuccessState).tasks,
    );
    for (int i = 0; i < optimisticTasks.length; i++) {
      if (optimisticTasks[i].taskId == event.taskId) {
        final newTask = TaskEntity(
          taskId: optimisticTasks[i].taskId,
          categoryId: optimisticTasks[i].categoryId,
          content: optimisticTasks[i].content,
          isRecurring: optimisticTasks[i].isRecurring,
          diamonds: optimisticTasks[i].diamonds,
          isDone: event.completed,
        );
        optimisticTasks[i] = newTask;
        break;
      }
    }
    emit(TasksSuccessState(tasks: optimisticTasks));

    final currentState = state;
    final res = await setTaskUseCase.call(
      SetTaskUseCaseParams(
        dayId: event.dayId,
        taskId: event.taskId,
        completed: event.completed,
      ),
    );
    res.fold((failure) {
      if (state == currentState) {
        final afterFailure = List<TaskEntity>.from(
          (state as TasksSuccessState).tasks,
        );
        for (int i = 0; i < afterFailure.length; i++) {
          if (afterFailure[i].taskId == event.taskId) {
            final newTask = TaskEntity(
              taskId: afterFailure[i].taskId,
              categoryId: afterFailure[i].categoryId,
              content: afterFailure[i].content,
              isRecurring: afterFailure[i].isRecurring,
              diamonds: afterFailure[i].diamonds,
              isDone: !event.completed,
            );
            afterFailure[i] = newTask;
            break;
          }
        }
        emit(TasksSuccessState(tasks: afterFailure));
      }
      emit(TasksFailureState(failure.message));
    }, (unit) {});
  }
}
