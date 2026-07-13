import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/studio_colors.dart';
import '../../../../core/widgets/glass_panel.dart';
import '../../presentation/bloc/equalizer_bloc.dart';

class EqualizerPage extends StatelessWidget {
  const EqualizerPage({super.key});

  static const _bandLabels = ['60Hz', '230Hz', '910Hz', '3.6k', '14k'];

  /// MiniMax product-color sequence for EQ bars (not used for CTAs).
  static const _bandColors = [
    StudioColors.brandCoral,
    StudioColors.brandMagenta,
    StudioColors.brandPurple,
    StudioColors.brandBlue,
    StudioColors.brandCyan,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StudioColors.canvas,
      appBar: AppBar(
        title: Text(
          'Equalizer',
          style: GoogleFonts.dmSans(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: StudioColors.ink,
          ),
        ),
      ),
      body: BlocBuilder<EqualizerBloc, EqualizerState>(
        builder: (context, state) {
          if (state is! EqualizerReady) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              Text(
                'Tune your sound',
                style: GoogleFonts.dmSans(
                  color: StudioColors.ink,
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Pick a preset — bands light up in brand color.',
                style: GoogleFonts.dmSans(
                  color: StudioColors.steel,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final preset in state.presets)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _PresetPill(
                          label: preset.name,
                          selected: state.selected.id == preset.id,
                          onTap: () => context
                              .read<EqualizerBloc>()
                              .add(SelectPreset(preset)),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              GlassPanel(
                borderRadius: 24,
                blur: 18,
                tint: StudioColors.surface.withValues(alpha: 0.9),
                padding: const EdgeInsets.fromLTRB(16, 28, 16, 20),
                child: SizedBox(
                  height: 220,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (var i = 0; i < 5; i++)
                        _BandBar(
                          label: _bandLabels[i],
                          gain: state.bands[i],
                          color: _bandColors[i],
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Android applies EQ in real time. On iOS, the preset is saved for when playback supports it.',
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  color: StudioColors.stone,
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PresetPill extends StatelessWidget {
  const _PresetPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? StudioColors.primary : StudioColors.canvas,
      shape: StadiumBorder(
        side: BorderSide(
          color: selected ? StudioColors.primary : StudioColors.hairline,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(
            label,
            style: GoogleFonts.dmSans(
              color: selected ? StudioColors.onPrimary : StudioColors.steel,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

class _BandBar extends StatelessWidget {
  const _BandBar({
    required this.label,
    required this.gain,
    required this.color,
  });

  final String label;
  final double gain;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final normalized = ((gain + 12) / 24).clamp(0.0, 1.0);
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          gain >= 0 ? '+${gain.toInt()}' : '${gain.toInt()}',
          style: GoogleFonts.dmSans(
            color: StudioColors.steel,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 40,
          height: 160 * normalized + 24,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                color,
                Color.lerp(color, Colors.white, 0.35)!,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.35),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: GoogleFonts.dmSans(
            color: StudioColors.steel,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
