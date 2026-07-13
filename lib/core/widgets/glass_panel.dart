import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/studio_colors.dart';

/// Frosted glass surface — MiniMax light chrome.
class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.borderRadius = 16,
    this.blur = 18,
    this.tint,
    this.borderOpacity = 0.9,
    this.padding,
    this.clipBehavior = Clip.antiAlias,
  });

  final Widget child;
  final double borderRadius;
  final double blur;
  final Color? tint;
  final double borderOpacity;
  final EdgeInsetsGeometry? padding;
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);
    return ClipRRect(
      borderRadius: radius,
      clipBehavior: clipBehavior,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: radius,
            color: tint ?? StudioColors.glassFill,
            border: Border.all(
              color: StudioColors.hairline.withValues(alpha: borderOpacity),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 16,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: padding == null
              ? child
              : Padding(padding: padding!, child: child),
        ),
      ),
    );
  }
}

class GlassDock extends StatelessWidget {
  const GlassDock({
    super.key,
    required this.child,
    this.blur = 22,
  });

  final Widget child;
  final double blur;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: StudioColors.glassDock,
            border: const Border(
              top: BorderSide(color: StudioColors.hairlineSoft),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
