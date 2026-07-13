import 'package:flutter/material.dart';

import '../theme/studio_colors.dart';

class StudioPillButton extends StatelessWidget {
  const StudioPillButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.filled = true,
    this.tone = StudioPillTone.ink,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool filled;
  final StudioPillTone tone;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(9999);
    final enabled = onPressed != null;
    final Color fill;
    final Color border;
    final Color foreground;
    switch (tone) {
      case StudioPillTone.ink:
        fill = StudioColors.primary;
        border = StudioColors.ink;
        foreground = filled ? StudioColors.onPrimary : StudioColors.ink;
      case StudioPillTone.saved:
        fill = StudioColors.brandCoral;
        border = StudioColors.brandCoral;
        foreground = filled ? StudioColors.onPrimary : StudioColors.brandCoral;
    }

    if (filled) {
      return Opacity(
        opacity: enabled ? 1 : 0.9,
        child: Material(
          color: fill,
          borderRadius: radius,
          child: InkWell(
            onTap: onPressed,
            borderRadius: radius,
            child: _content(foreground),
          ),
        ),
      );
    }

    return Opacity(
      opacity: enabled ? 1 : 0.9,
      child: Material(
        color: StudioColors.canvas,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: border, width: 1.5),
        ),
        child: InkWell(
          onTap: onPressed,
          borderRadius: radius,
          child: _content(foreground),
        ),
      ),
    );
  }

  Widget _content(Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

enum StudioPillTone { ink, saved }
