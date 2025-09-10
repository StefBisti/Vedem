import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vedem/core/pages/day_page.dart';
import 'package:vedem/core/style/app_colors.dart';
import 'package:vedem/core/style/app_style.dart';
import 'package:vedem/core/style/app_text_styles.dart';
import 'package:vedem/core/utils/time_utils.dart';
import 'package:vedem/features/highlights/domain/entities/highlight_cache_quality.dart';
import 'package:vedem/features/highlights/domain/entities/highlight_entity.dart';
import 'package:vedem/features/highlights/presentation/cubit/highlights_cubit.dart';

class HighlightsCarouselImage extends StatelessWidget {
  final HighlightEntity highlight;
  final int highlightIndex;
  final double imageWidth;
  final Function()? onTap;
  final Widget? heartWidget;

  const HighlightsCarouselImage({
    required this.highlight,
    required this.highlightIndex,
    required this.imageWidth,
    this.onTap,
    this.heartWidget,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: imageWidth,
      height: imageWidth * 4 / 3,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(70),
            spreadRadius: 2,
            blurRadius: 10,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: OpenContainer(
        closedElevation: 0,
        openElevation: 0,
        closedColor: AppColors.lightBackgroundColor,
        openColor: AppColors.lightBackgroundColor,
        closedShape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(AppStyle.roundedCorners),
        ),
        openShape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(AppStyle.roundedCorners),
        ),
        closedBuilder: (context, openContainer) {
          return GestureDetector(
            onTap: () {
              if (onTap == null) {
                context.read<HighlightsCubit>().handleSelectedHighlightForDay(
                  highlightIndex,
                );
                openContainer();
              } else {
                onTap!();
              }
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                _getImage(),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withAlpha(100),
                          Colors.transparent,
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                Positioned(
                  bottom: 12,
                  left: 16,
                  child: Text(
                    TimeUtils.formatDayId(highlight.dayId),
                    style: AppTextStyles.heading.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black45,
                          blurRadius: 4,
                          offset: Offset(1, 1),
                        ),
                      ],
                    ),
                  ),
                ),

                Positioned(
                  top: 16,
                  right: 16,
                  child: heartWidget ?? SizedBox(),
                ),
              ],
            ),
          );
        },
        openBuilder: (ctx, _) {
          return DayPage(
            dayId: highlight.dayId,
            highlightsCubit: context.read<HighlightsCubit>(),
          );
        },
      ),
    );
  }

  Widget _getImage() {
    if (highlight.exists &&
        highlight.cacheQuality != HighlightCacheQuality.none) {
      return Image.memory(
        highlight.cachedImage!,
        fit: BoxFit.cover,
        gaplessPlayback: true,
      );
    } else if (highlight.exists &&
        highlight.cacheQuality == HighlightCacheQuality.none) {
      return Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: ColoredBox(color: Colors.black),
      );
    } else {
      return Image.asset(
        'assets/images/placeholder_highlight.png',
        fit: BoxFit.cover,
      );
    }
  }
}
