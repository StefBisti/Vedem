import 'package:flutter/material.dart';
import 'package:vedem/core/style/app_style.dart';
import 'package:vedem/core/style/app_text_styles.dart';
import 'package:vedem/features/tasks/domain/entities/task_done_type.dart';
import 'package:vedem/features/tasks/domain/entities/task_entity.dart';

class TaskWidgetDone extends StatefulWidget {
  final bool animate;
  final Function(TaskDoneType) onClaim;
  final TaskEntity task;
  final Color primaryColor;
  final Color secondaryColor;

  const TaskWidgetDone({
    super.key,
    required this.onClaim,
    required this.animate,
    required this.task,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  State<TaskWidgetDone> createState() => _TaskWidgetDoneState();
}

class _TaskWidgetDoneState extends State<TaskWidgetDone> {
  final int waitBeforeAnimation = 400;
  final int doneAnimationDuration = 300;
  final int claimAnimationDuration = 300;
  final int claimAnimInBetween = 200;

  final firstAnimationDone = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppStyle.roundedCorners),
        color: widget.primaryColor,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 4.0,
        children: [
          Expanded(
            child: TextButton(
              onPressed: () {
                widget.onClaim(TaskDoneType.notGreat);
              },
              style: TextButton.styleFrom(
                overlayColor: widget.primaryColor,
                backgroundColor: widget.secondaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.circular(4.0),
                ),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (constraints.maxHeight > 60)
                        Icon(
                          Icons.sentiment_dissatisfied_rounded,
                          color: widget.primaryColor,
                          size: 20.0,
                        ),
                      Text(
                        'Not great',
                        style: AppTextStyles.content.copyWith(
                          color: widget.primaryColor,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Claim ${widget.task.notGreatDiamonds}',
                            style: AppTextStyles.content.copyWith(
                              color: widget.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Icon(
                            Icons.diamond_rounded,
                            color: widget.primaryColor,
                            size: 16.0,
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),

          Expanded(
            child: TextButton(
              onPressed: () {
                widget.onClaim(TaskDoneType.onPoint);
              },
              style: TextButton.styleFrom(
                overlayColor: widget.primaryColor,
                backgroundColor: widget.secondaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.circular(4.0),
                ),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (constraints.maxHeight > 60)
                      Icon(
                        Icons.sentiment_satisfied_rounded,
                        color: widget.primaryColor,
                        size: 20.0,
                      ),
                    Text(
                      'On Point',
                      style: AppTextStyles.content.copyWith(
                        color: widget.primaryColor,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Claim ${widget.task.onPointDiamonds}',
                          style: AppTextStyles.content.copyWith(
                            color: widget.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Icon(
                          Icons.diamond_rounded,
                          color: widget.primaryColor,
                          size: 16.0,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          Expanded(
            child: TextButton(
              onPressed: () {
                widget.onClaim(TaskDoneType.awesome);
              },
              style: TextButton.styleFrom(
                overlayColor: widget.primaryColor,
                backgroundColor: widget.secondaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.circular(4.0),
                ),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (constraints.maxHeight > 60)
                      Icon(
                        Icons.sentiment_satisfied_rounded,
                        color: widget.primaryColor,
                        size: 20.0,
                      ),
                    Text(
                      'Awesome',
                      style: AppTextStyles.content.copyWith(
                        color: widget.primaryColor,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Claim ${widget.task.awesomeDiamonds}',
                          style: AppTextStyles.content.copyWith(
                            color: widget.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Icon(
                          Icons.diamond_rounded,
                          color: widget.primaryColor,
                          size: 16.0,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
