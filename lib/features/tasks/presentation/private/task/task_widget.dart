import 'dart:math';
import 'package:flutter/material.dart';
import 'package:vedem/features/tasks/domain/entities/subtask_entity.dart';
import 'package:vedem/features/tasks/domain/entities/task_done_type.dart';
import 'package:vedem/features/tasks/domain/entities/task_entity.dart';
import 'package:vedem/features/tasks/presentation/private/task/task_widget_body.dart';
import 'package:vedem/features/tasks/presentation/private/task/task_widget_done.dart';

class TaskWidget extends StatefulWidget {
  final TaskEntity task;
  final Color categoryPrimaryColor;
  final Color categorySecondaryColor;
  final Function(TaskDoneType)? onTaskToggled;
  final Function(int, bool)? onSubstaskToggled;
  final Function(int)? onClaimDiamonds;
  final Function()? onEdit;
  final Function()? onDelete;
  final Function()? onTaskPressed; // used when not toggled

  const TaskWidget({
    super.key,
    required this.task,
    required this.categoryPrimaryColor,
    required this.categorySecondaryColor,
    required this.onTaskToggled,
    required this.onSubstaskToggled,
    required this.onClaimDiamonds,
    required this.onEdit,
    required this.onDelete,
    required this.onTaskPressed,
  });

  @override
  State<TaskWidget> createState() => _TaskWidgetState();
}

class _TaskWidgetState extends State<TaskWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _doneAnimationController;
  double _maxSlide = 0.0;
  bool _animateCompletedPart = false;
  double endScale = 0.97;
  final scale = ValueNotifier<double>(1.0);

  @override
  void initState() {
    super.initState();
    _doneAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 250),
    );
  }

  @override
  void dispose() {
    _doneAnimationController.dispose();
    super.dispose();
  }

  void _onPointerDown(_) {
    if (widget.onTaskPressed != null && widget.onSubstaskToggled == null) {
      scale.value = endScale;
    }

    if (widget.onTaskToggled != null &&
        widget.onSubstaskToggled != null &&
        widget.task.subtasks.isEmpty &&
        _doneAnimationController.value == 0) {
      scale.value = endScale;
    }
  }

  void _onPointerUp(_) {
    scale.value = 1.0;
  }

  void _onTap() {
    if (widget.onTaskPressed != null) {
      widget.onTaskPressed!();
    }

    if (widget.onTaskToggled == null || widget.onSubstaskToggled == null) {
      return;
    }

    if (widget.task.subtasks.isNotEmpty) return;

    if (widget.task.onPointDiamonds == null) {
      if (widget.task.taskDoneType == TaskDoneType.notDone) {
        widget.onTaskToggled!(TaskDoneType.onPoint);
      } else {
        widget.onTaskToggled!(TaskDoneType.notDone);
      }
      _doneAnimationController.value = 0.0;
      return;
    }

    if (widget.task.taskDoneType == TaskDoneType.notDone) {
      final renderBox = context.findRenderObject() as RenderBox;
      _maxSlide = renderBox.size.height;
      _doneAnimationController.forward().whenComplete(() {
        setState(() {
          _animateCompletedPart = true;
        });
      });
    } else {
      widget.onTaskToggled!(TaskDoneType.notDone);
    }
  }

  void _onClaim(TaskDoneType doneType) {
    _doneAnimationController.value = 0.0;
    if (widget.task.onPointDiamonds == null ||
        widget.onTaskToggled == null ||
        widget.onClaimDiamonds == null) {
      return;
    }
    widget.onTaskToggled!(doneType);
    widget.onClaimDiamonds!(widget.task.getDiamonds(doneType));
  }

  void _handleOnSubtaskToggled(int index, bool completed) {
    if (widget.onTaskPressed != null) {
      widget.onTaskPressed!();
    }
    
    if (widget.onSubstaskToggled == null) return;

    widget.onSubstaskToggled!(index, completed);
    List<SubtaskEntity> newSubtasks = List.from(widget.task.subtasks);
    newSubtasks[index] = newSubtasks[index].copyWith(completed: completed);

    final bool allCompleted = newSubtasks.every((s) => s.completed);
    if (allCompleted && widget.task.taskDoneType == TaskDoneType.notDone) {
      if (widget.task.onPointDiamonds == null) {
        widget.onTaskToggled!(TaskDoneType.onPoint);
        _doneAnimationController.value = 0.0;
        return;
      }
      final renderBox = context.findRenderObject() as RenderBox;
      _maxSlide = renderBox.size.height;
      _doneAnimationController.forward().whenComplete(() {
        setState(() {
          _animateCompletedPart = true;
        });
      });
    } else if (allCompleted == false &&
        widget.task.taskDoneType != TaskDoneType.notDone &&
        widget.onTaskToggled != null) {
      widget.onTaskToggled!(TaskDoneType.notDone);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _onPointerDown,
      onPointerUp: _onPointerUp,
      onPointerCancel: _onPointerUp,
      child: ValueListenableBuilder(
        valueListenable: scale,
        builder: (context, value, child) {
          return Transform.scale(scale: value, child: child);
        },
        child: GestureDetector(
          onTap: _onTap,
          child: AnimatedBuilder(
            animation: _doneAnimationController,
            builder: (context, child) {
              return Stack(
                children: [
                  Transform.translate(
                    offset: Offset(
                      0.0,
                      _maxSlide * _doneAnimationController.value,
                    ),
                    child: Transform(
                      alignment: Alignment.topCenter,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.002)
                        ..rotateX(pi / 2 * _doneAnimationController.value),
                      child: TaskWidgetBody(
                        task: widget.task,
                        primaryColor: widget.categoryPrimaryColor,
                        secondaryColor: widget.categorySecondaryColor,
                        onEdit: widget.onEdit,
                        onDelete: widget.onDelete,
                        onSubtaskToggled: _handleOnSubtaskToggled,
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Transform.translate(
                      offset: Offset(
                        0.0,
                        _maxSlide * (_doneAnimationController.value - 1),
                      ),
                      child: Transform(
                        alignment: Alignment.bottomCenter,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.002)
                          ..rotateX(
                            -pi / 2 * (1 - _doneAnimationController.value),
                          ),
                        child: TaskWidgetDone(
                          onClaim: _onClaim,
                          animate: _animateCompletedPart,
                          task: widget.task,
                          primaryColor: widget.categoryPrimaryColor,
                          secondaryColor: widget.categorySecondaryColor,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
