import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:vedem/core/style/app_text_styles.dart';

class TaskWidgetDone extends StatelessWidget {
  final Color color;
  final bool animate;
  final int notGreatDiamonds, onPointDiamonds, awesomeDiamonds;
  final Function(int) onClaim;

  const TaskWidgetDone({
    super.key,
    required this.color,
    required this.animate,
    required this.onClaim,
    required this.notGreatDiamonds,
    required this.onPointDiamonds,
    required this.awesomeDiamonds,
  });

  final int waitBeforeAnimation = 400;
  final int doneAnimationDuration = 300;
  final int claimAnimationDuration = 300;
  final int claimAnimInBetween = 200;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: color.withAlpha(100),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_rounded, size: 24.0, color: color),
                  SizedBox(width: 8.0),
                  Text(
                    'Completed',
                    style: AppTextStyles.heading.copyWith(color: color),
                  ),
                ],
              )
              .animate(target: animate ? 1 : 0)
              .moveY(
                delay: Duration(milliseconds: waitBeforeAnimation),
                duration: Duration(milliseconds: doneAnimationDuration),
                begin: 0,
                end: 20,
              )
              .fadeOut(
                delay: Duration(milliseconds: waitBeforeAnimation),
                duration: Duration(milliseconds: doneAnimationDuration),
              ),

          SizedBox.expand(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 8.0,
              children: [
                Expanded(
                      child: TextButton(
                        onPressed: () {
                          onClaim(notGreatDiamonds);
                        },
                        style: TextButton.styleFrom(
                          side: BorderSide(color: color, width: 1.0),
                          overlayColor: color,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.sentiment_dissatisfied_rounded,
                              color: color,
                              size: 20.0,
                            ),
                            Text(
                              'Not great',
                              style: AppTextStyles.content.copyWith(
                                color: color,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Claim $notGreatDiamonds',
                                  style: AppTextStyles.content.copyWith(
                                    color: color,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Icon(
                                  Icons.diamond_rounded,
                                  color: color,
                                  size: 16.0,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                    .animate(target: animate ? 1 : 0)
                    .moveY(
                      duration: Duration(milliseconds: doneAnimationDuration),
                      delay: Duration(
                        milliseconds:
                            waitBeforeAnimation +
                            doneAnimationDuration +
                            claimAnimInBetween * 0,
                      ),
                    )
                    .fadeIn(
                      duration: Duration(milliseconds: doneAnimationDuration),
                      delay: Duration(
                        milliseconds:
                            waitBeforeAnimation +
                            doneAnimationDuration +
                            claimAnimInBetween * 0,
                      ),
                    ),
                Expanded(
                      child: TextButton(
                        onPressed: () {
                          onClaim(onPointDiamonds);
                        },
                        style: TextButton.styleFrom(
                          side: BorderSide(color: color, width: 1.0),
                          overlayColor: color,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.sentiment_satisfied_rounded,
                              color: color,
                              size: 20.0,
                            ),
                            Text(
                              'On Point',
                              style: AppTextStyles.content.copyWith(
                                color: color,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Claim $onPointDiamonds',
                                  style: AppTextStyles.content.copyWith(
                                    color: color,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Icon(
                                  Icons.diamond_rounded,
                                  color: color,
                                  size: 16.0,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                    .animate(target: animate ? 1 : 0)
                    .moveY(
                      duration: Duration(milliseconds: doneAnimationDuration),
                      delay: Duration(
                        milliseconds:
                            waitBeforeAnimation +
                            doneAnimationDuration +
                            claimAnimInBetween * 1,
                      ),
                    )
                    .fadeIn(
                      duration: Duration(milliseconds: doneAnimationDuration),
                      delay: Duration(
                        milliseconds:
                            waitBeforeAnimation +
                            doneAnimationDuration +
                            claimAnimInBetween * 1,
                      ),
                    ),
                Expanded(
                      child: TextButton(
                        onPressed: () {
                          onClaim(awesomeDiamonds);
                        },
                        style: TextButton.styleFrom(
                          side: BorderSide(color: color, width: 1.0),
                          overlayColor: color,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.sentiment_very_satisfied_rounded,
                              color: color,
                              size: 20.0,
                            ),
                            Text(
                              'Awesome',
                              style: AppTextStyles.content.copyWith(
                                color: color,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Claim $awesomeDiamonds',
                                  style: AppTextStyles.content.copyWith(
                                    color: color,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Icon(
                                  Icons.diamond_rounded,
                                  color: color,
                                  size: 16.0,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                    .animate(target: animate ? 1 : 0)
                    .moveY(
                      duration: Duration(milliseconds: doneAnimationDuration),
                      delay: Duration(
                        milliseconds:
                            waitBeforeAnimation +
                            doneAnimationDuration +
                            claimAnimInBetween * 2,
                      ),
                    )
                    .fadeIn(
                      duration: Duration(milliseconds: doneAnimationDuration),
                      delay: Duration(
                        milliseconds:
                            waitBeforeAnimation +
                            doneAnimationDuration +
                            claimAnimInBetween * 2,
                      ),
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
