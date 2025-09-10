import 'package:flutter/material.dart';
import 'package:vedem/core/style/app_colors.dart';

class CarouselHeartDisplay extends StatelessWidget {
  final bool hearted;
  final Function() onUnheart;

  const CarouselHeartDisplay({
    super.key,
    required this.hearted,
    required this.onUnheart,
  });

  @override
  Widget build(BuildContext context) {
    if (hearted == false) return SizedBox();
    return GestureDetector(
      onTap: onUnheart,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.lightBackgroundColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(51),
              blurRadius: 6,
              spreadRadius: 1,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Icon(Icons.favorite_rounded, color: Colors.red, size: 24.0),
      ),
    );
  }
}
