import 'package:flutter/material.dart';

import '../theme/studio_colors.dart';

class StudioPillButton extends StatelessWidget {
  const StudioPillButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.filled = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(9999);
    if (filled) {
      return Material(
        color: StudioColors.primary,
        borderRadius: radius,
        child: InkWell(
          onTap: onPressed,
          borderRadius: radius,
          child: _content(onDark: true),
        ),
      );
    }

    return Material(
      color: StudioColors.canvas,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: const BorderSide(color: StudioColors.ink),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: radius,
        child: _content(onDark: false),
      ),
    );
  }

  Widget _content({required bool onDark}) {
    final color = onDark ? StudioColors.onPrimary : StudioColors.ink;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 11),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
          ],
          Text(
            label,
          style: TextStyle(
              color: onDark ? StudioColors.onPrimary : StudioColors.ink,
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
