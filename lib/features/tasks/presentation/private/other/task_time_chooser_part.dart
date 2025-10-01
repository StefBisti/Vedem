import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:vedem/core/style/app_text_styles.dart';
import 'package:vedem/core/utils/math_utils.dart';

class TaskTimeChooserPart extends StatefulWidget {
  final bool enabled;
  final Function(int) onChanged;
  final int min, max;
  final double value;
  final Color minColor, maxColor;
  final Color disabledMaxColor;
  final Curve translationCurve;
  final Curve rotationCurve;
  final Curve scalationCurve;
  final Curve colorCurve;
  final double fullColorThreshold;

  const TaskTimeChooserPart({
    super.key,
    required this.enabled,
    required this.onChanged,
    required this.min,
    required this.max,
    required this.value,
    required this.minColor,
    required this.maxColor,
    required this.disabledMaxColor,
    required this.translationCurve,
    required this.rotationCurve,
    required this.scalationCurve,
    required this.colorCurve,
    required this.fullColorThreshold,
  });

  @override
  State<TaskTimeChooserPart> createState() => _TaskTimeChooserPartState();
}

class _TaskTimeChooserPartState extends State<TaskTimeChooserPart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  int previousSentValue = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController.unbounded(
      vsync: this,
      value: widget.value,
    );
    previousSentValue = widget.value.round();
  }

  void _sendValue() {
    if (widget.enabled == false) return;
    final rounded = _animationController.value.round();
    if (rounded != previousSentValue) {
      previousSentValue = rounded;
      widget.onChanged(
        _wrapInRange(widget.min, widget.max, rounded.toDouble()).toInt(),
      );
    }
  }

  void _onVerticalDragStart(DragStartDetails details) {
    _animationController.stop();
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    if (widget.enabled == false) return;
    _animationController.value =
        _animationController.value - (details.primaryDelta! / 20.0);
    _sendValue();
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    if (widget.enabled == false) return;
    final nearest = _animationController.value.round();
    _animationController
        .animateTo(
          nearest.toDouble(),
          duration: Duration(milliseconds: 200),
          curve: Curves.easeOut,
        )
        .then((_) => _sendValue());
  }

  double _wrapInRange(int min, int max, double val) {
    int size = max - min + 1;
    return ((val - min) % size + size) % size + min;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90.0,
      width: 50.0,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onVerticalDragStart: _onVerticalDragStart,
        onVerticalDragUpdate: _onVerticalDragUpdate,
        onVerticalDragEnd: _onVerticalDragEnd,
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Stack(
              children: [
                for (int i = 2; i >= -2; i--)
                  Align(
                    alignment: Alignment.center,
                    child: _singlePart(
                      widget.min,
                      widget.max,
                      _animationController.value,
                      i,
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _singlePart(int min, int max, double value, int modifier) {
    final startTranslate = 0.0;
    final endTranslate = 45.0;

    final minRotation = 0.0;
    final maxRotation = math.pi / 2;

    final minScale = 1.0;
    final maxScale = 1.0;

    final double middle = value.roundToDouble();
    final double lerpFactor =
        invLerp(value - 2.5, value + 2.5, middle + modifier) * 2 - 1;

    final translation = lerpFactor >= 0
        ? lerp(
            startTranslate,
            endTranslate,
            widget.translationCurve.transform(lerpFactor),
          )
        : -lerp(
            startTranslate,
            endTranslate,
            widget.translationCurve.transform(-lerpFactor),
          );
    final scalation = lerp(
      minScale,
      maxScale,
      widget.scalationCurve.transform(1 - lerpFactor.abs()),
    );
    final rotation = lerpFactor >= 0
        ? lerp(
            minRotation,
            maxRotation,
            widget.rotationCurve.transform(lerpFactor),
          )
        : -lerp(
            minRotation,
            maxRotation,
            widget.rotationCurve.transform(-lerpFactor),
          );
    final color = Color.lerp(
      widget.minColor,
      widget.enabled ? widget.maxColor : widget.disabledMaxColor,
      widget.colorCurve.transform(
        math.min(1, 1 - lerpFactor.abs() + widget.fullColorThreshold),
      ),
    );

    return Visibility(
      visible: true, //middle + modifier >= min && middle + modifier <= max,
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..translate(0.0, translation)
          ..setEntry(3, 2, 0.001)
          ..rotateX(rotation)
          ..scale(scalation),
        child: Text(
          _wrapInRange(
            min,
            max,
            middle + modifier,
          ).toStringAsFixed(0).padLeft(2, '0'),
          style: AppTextStyles.heading.copyWith(color: color,  fontSize: 30),
        ),
      ),
    );
  }
}
