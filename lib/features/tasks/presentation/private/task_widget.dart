import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vedem/features/tasks/domain/entities/task_entity.dart';
import 'package:vedem/features/tasks/presentation/bloc/tasks_bloc.dart';
import 'package:vedem/features/tasks/presentation/private/task_widget_body.dart';
import 'package:vedem/features/tasks/presentation/private/task_widget_done.dart';

class TaskWidget extends StatefulWidget {
  final String? dayId;
  final TaskEntity task;
  final List<Color> categoryColors; // temp

  const TaskWidget({
    super.key,
    required this.dayId,
    required this.task,
    required this.categoryColors,
  });

  @override
  State<TaskWidget> createState() => _TaskWidgetState();
}

class _TaskWidgetState extends State<TaskWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  double _maxSlide = 0.0;
  bool animateDone = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 250),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTap() {
    if (widget.dayId == null) return;

    if (widget.task.isDone == false) {
      final renderBox = context.findRenderObject() as RenderBox;
      _maxSlide = renderBox.size.height;
      _animationController.forward().whenComplete(() {
        setState(() {
          animateDone = true;
        });
      });
    } else {
      context.read<TasksBloc>().add(
        SetTaskEvent(
          dayId: widget.dayId!,
          taskId: widget.task.taskId,
          completed: false,
        ),
      );
    }
  }

  void _onClaim(int diamonds) {
    context.read<TasksBloc>().add(
      SetTaskEvent(
        dayId: widget.dayId!,
        taskId: widget.task.taskId,
        completed: true,
      ),
    );
    _animationController.value = 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Stack(
            children: [
              Transform.translate(
                offset: Offset(0.0, _maxSlide * _animationController.value),
                child: Transform(
                  alignment: Alignment.topCenter,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.002)
                    ..rotateX(pi / 2 * _animationController.value),
                  child: TaskWidgetBody(
                    dayId: widget.dayId,
                    taskId: widget.task.taskId,
                    categoryIndex: widget.task.categoryId,
                    content: widget.task.content,
                    diamonds: widget.task.diamonds,
                    isRecurring: widget.task.isRecurring,
                    isDone: widget.task.isDone,
                  ),
                ),
              ),
              Positioned.fill(
                child: Transform.translate(
                  offset: Offset(
                    0.0,
                    _maxSlide * (_animationController.value - 1),
                  ),
                  child: Transform(
                    alignment: Alignment.bottomCenter,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.002)
                      ..rotateX(-pi / 2 * (1 - _animationController.value)),
                    child: TaskWidgetDone(
                      animate: animateDone,
                      color:
                          widget.categoryColors[min(
                            widget.task.categoryId,
                            widget.categoryColors.length - 1,
                          )],
                      notGreatDiamonds: (widget.task.diamonds * 0.8).round(),
                      onPointDiamonds: widget.task.diamonds,
                      awesomeDiamonds: (widget.task.diamonds * 1.2).round(),
                      onClaim: _onClaim,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
