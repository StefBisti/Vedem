import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vedem/core/style/app_text_styles.dart';
import 'package:vedem/core/utils/misc_utils.dart';
import 'package:vedem/core/utils/time_utils.dart';
import 'package:vedem/features/highlights/domain/entities/highlight_cache_quality.dart';
import 'package:vedem/features/highlights/domain/entities/highlight_entity.dart';
import 'package:vedem/features/highlights/presentation/cubit/highlights_cubit.dart';

class HighlightsGalleryDisplay extends StatelessWidget {
  const HighlightsGalleryDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HighlightsCubit, HighlightsState>(
      listener: (context, state) {
        if (state.error != null) {
          MiscUtils.showSnackBar(context, state.error!);
        }
        // print('#############################');
        // for (int i = 0; i < state.highlights.length; i++) {
        //   print(
        //     "$i - ${state.highlights[i].dayId}, ${state.highlights[i].exists}, ${state.highlights[i].cacheQuality}, ${(state.highlights[i].cachedImage ?? Uint8List(0)).length}",
        //   );
        // }
      },
      builder: (context, state) {
        int crossAxisCount = 2;
        return MasonryGridView.count(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: state.highlights.length,
          itemBuilder: (context, index) {
            return Stack(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: _getImage(state.highlights[index]),
                ),
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
                  bottom: 4,
                  left: 8,
                  child: Text(
                    TimeUtils.formatDayId(state.highlights[index].dayId),
                    style: AppTextStyles.content.copyWith(
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

                // Positioned(
                //   top: 16,
                //   right: 16,
                //   child: heartWidget ?? SizedBox(),
                // ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _getImage(HighlightEntity highlight) {
    if (highlight.exists == false) {
      return Image.asset('assets/images/placeholder_highlight.png');
    }
    if (highlight.cacheQuality == HighlightCacheQuality.none) {
      return Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: ColoredBox(color: Colors.black),
      );
    }
    return Image.memory(
      highlight.cachedImage!,
      fit: BoxFit.cover,
      filterQuality: FilterQuality.low,
      gaplessPlayback: true,
    );
  }
}
