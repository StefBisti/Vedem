import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:vedem/core/style/app_colors.dart';
import 'package:vedem/features/highlights/presentation/cubit/highlights_cubit.dart';
import 'package:vedem/features/highlights/presentation/public/highlights_gallery_display.dart';

class GalleryPage extends StatelessWidget {
  const GalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              GetIt.instance<HighlightsCubit>()..loadHighlightsForGallery(),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          scrolledUnderElevation: 0.0,
          elevation: 0.0,
          toolbarHeight: 0.0,
          backgroundColor: AppColors.darkBackgroundColor.withAlpha(100),
        ),
        backgroundColor: AppColors.primaryLightTextColor,
        extendBodyBehindAppBar: true,
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 50),
              HighlightsGalleryDisplay(),
              SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
