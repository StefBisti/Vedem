import 'package:flutter/material.dart';

class CreateTaskGradient extends StatelessWidget {
  const CreateTaskGradient({super.key, required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 500),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withAlpha(48), Colors.transparent],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }
}
