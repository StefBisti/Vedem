import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vedem/core/error/error_messages.dart';
import 'package:vedem/features/tasks/domain/entities/task_entity.dart';
import 'package:vedem/features/tasks/domain/usecases/create_new_task_use_case.dart';
import 'package:vedem/features/tasks/domain/usecases/delete_task_usecase.dart';
import 'package:vedem/features/tasks/domain/usecases/initialize_tasks_for_day_use_case.dart';
import 'package:vedem/features/tasks/domain/usecases/read_tasks_for_day_usecase.dart';
import 'package:vedem/features/tasks/domain/usecases/read_tasks_for_month_use_case.dart';
import 'package:vedem/features/tasks/domain/usecases/set_task_usecase.dart';
import 'package:vedem/features/tasks/domain/usecases/update_task_usecase.dart';

part 'tasks_event.dart';
part 'tasks_state.dart';

class TasksBloc extends Bloc<TasksEvent, TasksState> {
  final CreateNewTaskUseCase createNewTaskUseCase;
  final InitializeTasksForDayUseCase initializeTasksForDayUseCase;
  final ReadTasksForDayUseCase readTasksForDayUseCase;
  final ReadTasksForMonthUseCase readTasksForMonthUseCase;
  final UpdateTaskUseCase updateTaskUseCase;
  final DeleteTaskUseCase deleteTaskUseCase;
  final SetTaskUseCase setTaskUseCase;

  TasksBloc({
    required this.createNewTaskUseCase,
    required this.initializeTasksForDayUseCase,
    required this.readTasksForDayUseCase,
    required this.readTasksForMonthUseCase,
    required this.updateTaskUseCase,
    required this.deleteTaskUseCase,
    required this.setTaskUseCase,
  }) : super(const TasksState()) {
    on<CreateNewTaskEvent>(_onCreateNewTaskEvent);
    on<InitializeTasksForDayEvent>(_onInitializeTasksForDayEvent);
    on<ReadTasksForDayEvent>(_onReadTasksForDayEvent);
    on<ReadTasksForMonthEvent>(_onReadTasksForMonthEvent);
    on<UpdateTaskEvent>(_onUpdateTaskEvent);
    on<DeleteTaskEvent>(_onDeleteTaskEvent);
    on<SetTaskEvent>(_onSetTaskEvent);
  }

  void _onCreateNewTaskEvent(
    CreateNewTaskEvent event,
    Emitter<TasksState> emit,
  ) async {
    if (state.isLoading) {
      emit(state.copyWith(error: noOperationWhileIsLoadingError));
      return;
    }

    final tempTask = TaskEntity(
      taskId: -1,
      categoryId: event.categoryId,
      content: event.content,
      isRecurring: event.isRecurring,
      diamonds: event.diamonds,
      isDone: false,
    );

    final optimisticTasks = List<TaskEntity>.from(state.tasks)..add(tempTask);
    emit(TasksState(tasks: optimisticTasks, isLoading: true, error: null));

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
        final afterFailure = state.tasks.where((t) => t.taskId != -1).toList();
        emit(
          TasksState(
            tasks: afterFailure,
            isLoading: false,
            error: failure.message,
          ),
        );
      },
      (createdTask) {
        final replaced = state.tasks
            .map((t) => t.taskId == -1 ? createdTask : t)
            .toList();
        emit(TasksState(tasks: replaced, isLoading: false, error: null));
      },
    );
  }

  void _onInitializeTasksForDayEvent(
    InitializeTasksForDayEvent event,
    Emitter<TasksState> emit,
  ) async {
    if (state.isLoading) {
      emit(state.copyWith(error: noOperationWhileIsLoadingError));
      return;
    }
    emit(TasksState(tasks: [], isLoading: true, error: null));
    final res = await initializeTasksForDayUseCase.call(
      InitializeTasksForDayUseCaseParams(dayId: event.dayId),
    );
    res.fold(
      (failure) =>
          emit(TasksState(tasks: [], isLoading: false, error: failure.message)),
      (initialTasks) =>
          emit(TasksState(tasks: initialTasks, isLoading: false, error: null)),
    );
  }

  void _onReadTasksForDayEvent(
    ReadTasksForDayEvent event,
    Emitter<TasksState> emit,
  ) async {
    if (state.isLoading) {
      emit(state.copyWith(error: noOperationWhileIsLoadingError));
      return;
    }

    if (event.alsoInitialize) {
      emit(TasksState(tasks: [], isLoading: true, error: null));
      final res = await initializeTasksForDayUseCase.call(
        InitializeTasksForDayUseCaseParams(dayId: event.dayId),
      );
      res.fold(
        (failure) => emit(
          TasksState(tasks: [], isLoading: false, error: failure.message),
        ),
        (initialTasks) => emit(
          TasksState(tasks: initialTasks, isLoading: false, error: null),
        ),
      );
    }

    emit(TasksState(tasks: [], isLoading: true, error: null));
    final res = await readTasksForDayUseCase.call(
      ReadTasksForDayUseCaseParams(dayId: event.dayId),
    );
    res.fold(
      (failure) =>
          emit(TasksState(tasks: [], isLoading: false, error: failure.message)),
      (dayTasks) =>
          emit(TasksState(tasks: dayTasks, isLoading: false, error: null)),
    );
  }

  void _onReadTasksForMonthEvent(
    ReadTasksForMonthEvent event,
    Emitter<TasksState> emit,
  ) async {
    if (state.isLoading) {
      emit(state.copyWith(error: noOperationWhileIsLoadingError));
      return;
    }
    emit(TasksState(tasks: [], isLoading: true, error: null));
    final res = await readTasksForMonthUseCase.call(
      ReadTasksForMonthUseCaseParams(monthId: event.monthId),
    );
    res.fold(
      (failure) =>
          emit(TasksState(tasks: [], isLoading: false, error: failure.message)),
      (dayTasks) =>
          emit(TasksState(tasks: dayTasks, isLoading: false, error: null)),
    );
  }

  void _onUpdateTaskEvent(
    UpdateTaskEvent event,
    Emitter<TasksState> emit,
  ) async {
    if (state.isLoading) {
      emit(state.copyWith(error: noOperationWhileIsLoadingError));
      return;
    }

    final optimisticTasks = List<TaskEntity>.from(state.tasks);
    TaskEntity? previousTask;
    TaskEntity? newTask;
    for (int i = 0; i < optimisticTasks.length; i++) {
      if (optimisticTasks[i].taskId == event.taskId) {
        previousTask = optimisticTasks[i];
        newTask = previousTask.copyWith(
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
    if (previousTask == null) {
      emit(state.copyWith(error: genericError));
      return;
    }
    emit(TasksState(tasks: optimisticTasks, isLoading: true, error: null));

    final res = await updateTaskUseCase.call(
      UpdateTaskUseCaseParams(
        taskId: event.taskId,
        categoryId: event.newCategoryId,
        content: event.newContent,
        isRecurring: event.newIsRecurring,
        diamonds: event.newDiamonds,
      ),
    );
    res.fold(
      (failure) {
        final afterFailure = List<TaskEntity>.from(state.tasks);
        for (int i = 0; i < afterFailure.length; i++) {
          if (afterFailure[i].taskId == newTask!.taskId) {
            afterFailure[i] = previousTask!;
            break;
          }
        }
        emit(
          TasksState(
            tasks: afterFailure,
            isLoading: false,
            error: failure.message,
          ),
        );
      },
      (unit) {
        emit(state.copyWith(isLoading: false, error: null));
      },
    );
  }

  void _onDeleteTaskEvent(
    DeleteTaskEvent event,
    Emitter<TasksState> emit,
  ) async {
    if (state.isLoading) {
      emit(state.copyWith(error: noOperationWhileIsLoadingError));
      return;
    }

    final optimisticTasks = List<TaskEntity>.from(state.tasks);
    TaskEntity? deletedTask;
    int? deletedIndex;
    for (int i = 0; i < optimisticTasks.length; i++) {
      if (optimisticTasks[i].taskId == event.taskId) {
        deletedTask = optimisticTasks[i];
        deletedIndex = i;
        break;
      }
    }
    if (deletedTask == null) {
      emit(state.copyWith(error: genericError));
      return;
    }
    optimisticTasks.removeAt(deletedIndex!);
    emit(TasksState(tasks: optimisticTasks, isLoading: true, error: null));

    final res = await deleteTaskUseCase.call(
      DeleteTaskUseCaseParams(
        dayId: event.dayId,
        taskId: event.taskId,
        isRecurring: deletedTask.isRecurring,
      ),
    );
    res.fold(
      (failure) {
        final afterFailure = List<TaskEntity>.from(state.tasks);
        afterFailure.insert(deletedIndex!, deletedTask!);
        emit(
          TasksState(
            tasks: afterFailure,
            isLoading: false,
            error: failure.message,
          ),
        );
      },
      (unit) {
        emit(state.copyWith(isLoading: false, error: null));
      },
    );
  }

  void _onSetTaskEvent(SetTaskEvent event, Emitter<TasksState> emit) async {
    if (state.isLoading) {
      emit(state.copyWith(error: noOperationWhileIsLoadingError));
      return;
    }

    final optimisticTasks = List<TaskEntity>.from(state.tasks);
    bool found = false;
    for (int i = 0; i < optimisticTasks.length; i++) {
      if (optimisticTasks[i].taskId == event.taskId) {
        optimisticTasks[i] = optimisticTasks[i].copyWith(
          isDone: event.completed,
        );
        found = true;
        break;
      }
    }
    if (found == false) {
      emit(state.copyWith(error: genericError));
      return;
    }
    emit(TasksState(tasks: optimisticTasks, isLoading: true, error: null));

    final res = await setTaskUseCase.call(
      SetTaskUseCaseParams(
        dayId: event.dayId,
        taskId: event.taskId,
        completed: event.completed,
      ),
    );
    res.fold(
      (failure) {
        final afterFailure = List<TaskEntity>.from(state.tasks);
        for (int i = 0; i < afterFailure.length; i++) {
          if (afterFailure[i].taskId == event.taskId) {
            afterFailure[i] = afterFailure[i].copyWith(
              isDone: !event.completed,
            );
            break;
          }
        }
        emit(
          TasksState(
            tasks: afterFailure,
            isLoading: false,
            error: failure.message,
          ),
        );
      },
      (unit) {
        emit(state.copyWith(isLoading: false, error: null));
      },
    );
  }
}
