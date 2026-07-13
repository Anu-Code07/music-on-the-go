import 'package:flutter/material.dart';

import '../theme/studio_colors.dart';

class StudioCircularPlayButton extends StatelessWidget {
  const StudioCircularPlayButton({
    super.key,
    required this.isPlaying,
    required this.onPressed,
    this.size = 56,
  });

  final bool isPlaying;
  final VoidCallback onPressed;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: StudioColors.primary,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(
            isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
            color: StudioColors.onPrimary,
            size: size * 0.5,
          ),
        ),
      ),
    );
  }
}
