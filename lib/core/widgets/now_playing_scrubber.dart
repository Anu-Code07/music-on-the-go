import 'package:flutter/material.dart';

import '../theme/studio_colors.dart';

class NowPlayingScrubber extends StatelessWidget {
  const NowPlayingScrubber({
    super.key,
    required this.position,
    required this.duration,
    required this.onSeek,
    this.lightLabels = false,
  });

  final Duration position;
  final Duration? duration;
  final ValueChanged<Duration> onSeek;
  final bool lightLabels;

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final total = duration ?? Duration.zero;
    final maxMs = total.inMilliseconds > 0 ? total.inMilliseconds.toDouble() : 1.0;
    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 3,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
          ),
          child: Slider(
            value: position.inMilliseconds.clamp(0, maxMs.toInt()).toDouble(),
            max: maxMs,
            onChanged: (v) => onSeek(Duration(milliseconds: v.round())),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _fmt(position),
                style: TextStyle(
                  color: lightLabels
                      ? StudioColors.onPrimary.withValues(alpha: 0.7)
                      : StudioColors.steel,
                  fontSize: 12,
                ),
              ),
              Text(
                _fmt(total),
                style: TextStyle(
                  color: lightLabels
                      ? StudioColors.onPrimary.withValues(alpha: 0.7)
                      : StudioColors.steel,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
