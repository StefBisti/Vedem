import 'package:flutter/material.dart';
import 'package:vedem/core/style/app_colors.dart';
import 'package:vedem/core/style/app_text_styles.dart';

class HighlightHeaderChangeImage extends StatelessWidget {
  final bool imageExists;
  final Function() onChangeImageWithPhoto;
  final Function() onChangeImageWithGallery;
  final Function() onDeleteImage;

  const HighlightHeaderChangeImage({
    super.key,
    required this.imageExists,
    required this.onChangeImageWithPhoto,
    required this.onChangeImageWithGallery,
    required this.onDeleteImage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Change the image',
          style: AppTextStyles.heading.copyWith(
            color: AppColors.primaryLightTextColor,
          ),
        ),
        SizedBox(height: 8.0),
        Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 4.0,
          children: [
            IconButton(
              onPressed: onChangeImageWithPhoto,
              icon: Icon(
                Icons.photo_camera,
                color: AppColors.primaryLightTextColor,
                size: 24.0,
              ),
              style: IconButton.styleFrom(
                backgroundColor: Colors.black.withAlpha(128),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.circular(8.0),
                ),
              ),
            ),
            IconButton(
              onPressed: onChangeImageWithGallery,
              icon: Icon(
                Icons.photo_outlined,
                color: AppColors.primaryLightTextColor,
                size: 24.0,
              ),
              style: IconButton.styleFrom(
                backgroundColor: Colors.black.withAlpha(128),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.circular(8.0),
                ),
              ),
            ),
            if (imageExists)
              IconButton(
                onPressed: onDeleteImage,
                icon: Icon(
                  Icons.delete_rounded,
                  color: AppColors.primaryLightTextColor,
                  size: 24.0,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black.withAlpha(128),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(8.0),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
