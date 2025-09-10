import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vedem/core/utils/math_utils.dart';
import 'package:vedem/features/highlights/domain/entities/highlight_entity.dart';
import 'package:vedem/features/highlights/presentation/cubit/highlights_cubit.dart';
import 'package:vedem/features/highlights/presentation/private/highlights_carousel_image.dart';

class HighlightsCarousel extends StatefulWidget {
  final List<HighlightEntity> highlights;
  final List<Widget?> heartWidgets;

  const HighlightsCarousel({
    super.key,
    required this.highlights,
    required this.heartWidgets,
  });

  @override
  State<HighlightsCarousel> createState() => _HighlightsCarouselState();
}

class _HighlightsCarouselState extends State<HighlightsCarousel>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late double imageWidth;
  late double offSlide;

  final double maxSlide = 50.0, maxRotation = 0.07, minScale = 0.85;

  double sliderValue = 0.0;
  Offset startDrag = Offset.zero;
  double _dragStartScroll = 0.0;
  int lastListLength = 0;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController.unbounded(vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    imageWidth = MediaQuery.of(context).size.width / 2 + 100;
    offSlide = imageWidth / 2 - 25;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onHorizontalDragStart(DragStartDetails details) {
    _animationController.stop();
    _dragStartScroll = _animationController.value;
    startDrag = details.globalPosition;
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    _animationController.value =
        _dragStartScroll - (details.globalPosition.dx - startDrag.dx) / 300;

    _animationController.value = _animationController.value
        .clamp(0, widget.highlights.length - 1)
        .toDouble();
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    final double bias = 0.38;
    final double biasValue =
        _animationController.value +
        (_animationController.value - _dragStartScroll).sign * bias;
    final target = biasValue.roundToDouble();
    _animationController.animateTo(
      target,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _goToLeft() {
    if (_currentIndex == 0) return;
    _currentIndex--;
    _animationController.animateTo(
      _currentIndex.toDouble(),
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _goToRight() {
    if (_currentIndex == widget.highlights.length - 1) return;
    _currentIndex++;
    _animationController.animateTo(
      _currentIndex.toDouble(),
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  bool isIndexGood(int index) => index >= 0 && index < widget.highlights.length;
  int getGoodIndex(int index) => isIndexGood(index) ? index : 0;

  @override
  Widget build(BuildContext context) {
    if (widget.highlights.isEmpty) {
      return SizedBox();
    }
    if (lastListLength != widget.highlights.length) {
      lastListLength = widget.highlights.length;
      _currentIndex = lastListLength - 1;
      _animationController.value = lastListLength - 1;
    }
    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onHorizontalDragStart: _onHorizontalDragStart,
        onHorizontalDragUpdate: _onHorizontalDragUpdate,
        onHorizontalDragEnd: _onHorizontalDragEnd,
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            final value = _animationController.value;
            final t = value - value.floor();

            final currentIndex = value.round();
            if (currentIndex != _currentIndex) {
              _currentIndex = currentIndex;
              context.read<HighlightsCubit>().handleNewCarouselHighlightInFocus(
                currentIndex,
              );
            }

            final double mainSlide = t < 0.5
                ? lerp(0.0, -offSlide, 2 * t)
                : lerp(offSlide, 0.0, 2 * (t - 0.5));
            final double mainScale = t < 0.5
                ? lerp(1.0, minScale, 2 * t)
                : lerp(minScale, 1.0, 2 * (t - 0.5));

            final double middleSlide = t < 0.5
                ? lerp(maxSlide, offSlide, 2 * t)
                : lerp(offSlide, maxSlide, 2 * (t - 0.5));
            final double middleRotation = t < 0.5
                ? lerp(maxRotation, 0, 2 * t)
                : lerp(0, maxRotation, 2 * (t - 0.5));

            final double underSlide = t < 0.5
                ? lerp(-maxSlide, offSlide, 2 * t)
                : lerp(-offSlide, -maxSlide, 2 * (t - 0.5));
            final double underRotation = t < 0.5
                ? lerp(-maxRotation, 0, 2 * t)
                : lerp(0, -maxRotation, 2 * (t - 0.5));

            return Stack(
              alignment: Alignment.center,
              children: [
                Visibility(
                  visible: isIndexGood(currentIndex - 1),
                  child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..translate(underSlide)
                      ..rotateZ(underRotation)
                      ..scale(minScale),
                    child: HighlightsCarouselImage(
                      highlight:
                          widget.highlights[getGoodIndex(currentIndex - 1)],
                      highlightIndex: getGoodIndex(currentIndex - 1),
                      imageWidth: imageWidth,
                      onTap: _goToLeft,
                      heartWidget:
                          widget.heartWidgets[getGoodIndex(currentIndex - 1)],
                    ),
                  ),
                ),
                Visibility(
                  visible: isIndexGood(currentIndex + 1),
                  child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..translate(middleSlide)
                      ..rotateZ(middleRotation)
                      ..scale(minScale),
                    child: HighlightsCarouselImage(
                      highlight:
                          widget.highlights[getGoodIndex(currentIndex + 1)],
                      highlightIndex: getGoodIndex(currentIndex + 1),
                      imageWidth: imageWidth,
                      onTap: _goToRight,
                      heartWidget:
                          widget.heartWidgets[getGoodIndex(currentIndex + 1)],
                    ),
                  ),
                ),
                Visibility(
                  visible: isIndexGood(currentIndex),
                  child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..translate(mainSlide)
                      ..rotateZ(0.0)
                      ..scale(mainScale),
                    child: HighlightsCarouselImage(
                      highlight: widget.highlights[getGoodIndex(currentIndex)],
                      highlightIndex: getGoodIndex(currentIndex),
                      imageWidth: imageWidth,
                      heartWidget:
                          widget.heartWidgets[getGoodIndex(currentIndex)],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
