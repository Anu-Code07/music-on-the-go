import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/studio_colors.dart';

/// Animated brand splash shown after the native launch screen.
class AriaSplashPage extends StatefulWidget {
  const AriaSplashPage({super.key});

  @override
  State<AriaSplashPage> createState() => _AriaSplashPageState();
}

class _AriaSplashPageState extends State<AriaSplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _markFade;
  late final Animation<double> _markScale;
  late final Animation<double> _wordFade;
  late final Animation<Offset> _wordSlide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _markFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
    );
    _markScale = Tween<double>(begin: 0.86, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOutCubic),
      ),
    );
    _wordFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.35, 0.7, curve: Curves.easeOut),
    );
    _wordSlide = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.35, 0.75, curve: Curves.easeOutCubic),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FadeTransition(
                  opacity: _markFade,
                  child: ScaleTransition(
                    scale: _markScale,
                    child: Image.asset(
                      'assets/branding/app_icon.png',
                      width: 128,
                      height: 128,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                FadeTransition(
                  opacity: _wordFade,
                  child: SlideTransition(
                    position: _wordSlide,
                    child: Text(
                      'ARIA',
                      style: GoogleFonts.outfit(
                        color: StudioColors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                FadeTransition(
                  opacity: _wordFade,
                  child: Container(
                    width: 36,
                    height: 2,
                    decoration: BoxDecoration(
                      color: StudioColors.spotifyGreen,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
