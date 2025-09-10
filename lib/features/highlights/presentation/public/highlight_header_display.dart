import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vedem/core/style/app_colors.dart';
import 'package:vedem/core/utils/misc_utils.dart';
import 'package:vedem/features/highlights/domain/entities/highlight_cache_quality.dart';
import 'package:vedem/features/highlights/presentation/cubit/highlights_cubit.dart';
import 'package:vedem/features/highlights/presentation/private/highlight_header_change_image.dart';
import 'package:image_picker/image_picker.dart';

class HighlightHeaderDisplay extends StatefulWidget {
  final String dayId;
  final Widget shareWidget;
  final Widget heartWidget;

  const HighlightHeaderDisplay({
    super.key,
    required this.dayId,
    required this.shareWidget,
    required this.heartWidget,
  });

  @override
  State<HighlightHeaderDisplay> createState() => _HighlightHeaderDisplayState();
}

class _HighlightHeaderDisplayState extends State<HighlightHeaderDisplay> {
  bool isChangingImage = false;

  @override
  Widget build(BuildContext context) {
    int highlightIndex = context
        .read<HighlightsCubit>()
        .state
        .highlights
        .indexWhere((h) => h.dayId == widget.dayId);
    if (highlightIndex == -1) {
      return SafeArea(child: SizedBox());
    }
    return SizedBox(
      width: double.infinity,
      child: AspectRatio(
        aspectRatio: 1.0,
        child: Stack(
          fit: StackFit.expand,
          children: [
            BlocConsumer<HighlightsCubit, HighlightsState>(
              listener: (context, state) {
                if (state.error != null) {
                  MiscUtils.showSnackBar(context, state.error!);
                }
                // for (int i = 0; i < state.highlights.length; i++) {
                //   print(
                //     "$i - ${state.highlights[i].dayId}, ${state.highlights[i].exists}, ${state.highlights[i].cacheQuality}, ${(state.highlights[i].cachedImage ?? Uint8List(0)).length}",
                //   );
                // }
              },
              builder: (context, state) {
                
                if (state.highlights[highlightIndex].exists == false) {
                  return Image.asset('assets/images/placeholder_highlight.png');
                }
                if (state.highlights[highlightIndex].cacheQuality ==
                    HighlightCacheQuality.none) {
                  return Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: ColoredBox(color: Colors.black),
                  );
                }
                return Image.memory(
                  state.highlights[highlightIndex].cachedImage!,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.low,
                  gaplessPlayback: true,
                );
              },
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withAlpha(64),
                      Colors.transparent,
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  setState(() {
                    isChangingImage = !isChangingImage;
                  });
                },
              ),
            ),

            Positioned(
              left: 8.0,
              top: 8.0,
              child: SafeArea(
                child: FloatingActionButton(
                  heroTag: 'back',
                  mini: true,
                  backgroundColor: AppColors.lightBackgroundColor,
                  foregroundColor: AppColors.primaryDarkTextColor,
                  shape: CircleBorder(),
                  child: Icon(
                    Icons.arrow_back_rounded,
                    color: AppColors.primaryDarkTextColor,
                    size: 24.0,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    context
                        .read<HighlightsCubit>()
                        .handleUnselectedHighlightForDay(highlightIndex);
                  },
                ),
              ),
            ),
            Positioned(
              right: 8.0,
              top: 8.0,
              child: SafeArea(
                child: Row(
                  children: [
                    widget.shareWidget,
                    SizedBox(width: 8.0),
                    widget.heartWidget,
                  ],
                ),
              ),
            ),

            Positioned.fill(
              child: IgnorePointer(
                ignoring: isChangingImage == false,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      isChangingImage = !isChangingImage;
                    });
                  },
                  child: AnimatedOpacity(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    opacity: isChangingImage ? 1.0 : 0.0,
                    child: ColoredBox(color: Colors.black.withAlpha(150)),
                  ),
                ),
              ),
            ),
            Center(
              child: IgnorePointer(
                ignoring: isChangingImage == false,
                child: AnimatedOpacity(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  opacity: isChangingImage ? 1.0 : 0.0,
                  child: BlocBuilder<HighlightsCubit, HighlightsState>(
                    builder: (context, state) => HighlightHeaderChangeImage(
                      imageExists: state.highlights[highlightIndex].exists,
                      onChangeImageWithGallery: () {
                        context.read<HighlightsCubit>().changeHighlight(
                          highlightIndex,
                          ImageSource.gallery,
                        );
                        setState(() {
                          isChangingImage = false;
                        });
                      },
                      onChangeImageWithPhoto: () {
                        context.read<HighlightsCubit>().changeHighlight(
                          highlightIndex,
                          ImageSource.camera,
                        );
                        setState(() {
                          isChangingImage = false;
                        });
                      },
                      onDeleteImage: () {
                        context.read<HighlightsCubit>().deleteHighlight(
                          highlightIndex,
                        );
                        setState(() {
                          isChangingImage = false;
                        });
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
