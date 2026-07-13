import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/studio_colors.dart';
import '../../presentation/bloc/equalizer_bloc.dart';

class EqualizerPage extends StatelessWidget {
  const EqualizerPage({super.key});

  static const _bandLabels = ['60Hz', '230Hz', '910Hz', '3.6k', '14k'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Equalizer')),
      body: BlocBuilder<EqualizerBloc, EqualizerState>(
        builder: (context, state) {
          if (state is! EqualizerReady) {
            return const Center(child: CircularProgressIndicator());
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    for (final preset in state.presets)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(preset.name),
                          selected: state.selected.id == preset.id,
                          selectedColor: StudioColors.primary,
                          labelStyle: TextStyle(
                            color: state.selected.id == preset.id
                                ? StudioColors.onPrimary
                                : StudioColors.ink,
                            fontWeight: FontWeight.w600,
                          ),
                          backgroundColor: StudioColors.canvas,
                          side: const BorderSide(color: StudioColors.hairline),
                          onSelected: (_) => context
                              .read<EqualizerBloc>()
                              .add(SelectPreset(preset)),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (var i = 0; i < 5; i++)
                      _BandBar(
                        label: _bandLabels[i],
                        gain: state.bands[i],
                      ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Android applies EQ in real time. On iOS, preset is saved for when playback supports it.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: StudioColors.silver, fontSize: 12),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BandBar extends StatelessWidget {
  const _BandBar({required this.label, required this.gain});

  final String label;
  final double gain;

  @override
  Widget build(BuildContext context) {
    final normalized = ((gain + 12) / 24).clamp(0.0, 1.0);
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          gain >= 0 ? '+${gain.toInt()}' : '${gain.toInt()}',
          style: const TextStyle(color: StudioColors.silver, fontSize: 11),
        ),
        const SizedBox(height: 4),
        Container(
          width: 36,
          height: 160 * normalized + 20,
          decoration: BoxDecoration(
            color: StudioColors.brandCoral,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: StudioColors.silver, fontSize: 11)),
      ],
    );
  }
}
