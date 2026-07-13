import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/studio_colors.dart';

/// MiniMax-style vibrant product identity card (32px hero radius).
class ProductIdentityCard extends StatelessWidget {
  const ProductIdentityCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.color,
    this.badge,
    this.onTap,
    this.width = 168,
    this.height = 200,
    this.child,
  });

  final String title;
  final String subtitle;
  final Color color;
  final String? badge;
  final VoidCallback? onTap;
  final double width;
  final double height;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color,
              Color.lerp(color, Colors.black, 0.22)!,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.28),
              blurRadius: 22,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            if (badge != null)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: StudioColors.onPrimary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    badge!,
                    style: GoogleFonts.dmSans(
                      color: StudioColors.onPrimary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (child != null) ...[
                  Expanded(child: child!),
                  const SizedBox(height: 12),
                ] else
                  const Spacer(),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.dmSans(
                    color: StudioColors.onPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    height: 1.15,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.dmSans(
                    color: StudioColors.onPrimary.withValues(alpha: 0.8),
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AriaBadge extends StatelessWidget {
  const AriaBadge.newBadge({super.key})
      : label = 'NEW',
        bg = StudioColors.brandCoral,
        fg = StudioColors.onPrimary;

  final String label;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: GoogleFonts.dmSans(
          color: fg,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
