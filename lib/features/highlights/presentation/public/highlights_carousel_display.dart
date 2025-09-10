import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vedem/core/utils/misc_utils.dart';
import 'package:vedem/features/highlights/presentation/cubit/highlights_cubit.dart';
import 'package:vedem/features/highlights/presentation/private/highlights_carousel.dart';

class HighlightsCarouselDisplay extends StatelessWidget {
  const HighlightsCarouselDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HighlightsCubit, HighlightsState>(
      listener: (context, state) {
        if (state.error != null) {
          MiscUtils.showSnackBar(context, state.error!);
        }
        print('#############################');
        for (int i = 0; i < state.highlights.length; i++) {
          print(
            "$i - ${state.highlights[i].dayId}, ${state.highlights[i].exists}, ${state.highlights[i].cacheQuality}, ${(state.highlights[i].cachedImage ?? Uint8List(0)).length}",
          );
        }
      },
      builder: (context, state) {
        return HighlightsCarousel(highlights: state.highlights);
      },
    );
  }
}
