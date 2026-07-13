import 'package:equatable/equatable.dart';

class EqPreset extends Equatable {
  const EqPreset({
    required this.id,
    required this.name,
    required this.bands,
  });

  final String id;
  final String name;
  /// Five band gains in dB: 60Hz, 230Hz, 910Hz, 3.6kHz, 14kHz.
  final List<double> bands;

  @override
  List<Object?> get props => [id, name, bands];
}

class EqPresets {
  EqPresets._();

  static const flat = EqPreset(
    id: 'flat',
    name: 'Flat',
    bands: [0, 0, 0, 0, 0],
  );

  static const bassBoost = EqPreset(
    id: 'bass_boost',
    name: 'Bass Boost',
    bands: [6, 4, 0, 0, 0],
  );

  static const vocal = EqPreset(
    id: 'vocal',
    name: 'Vocal',
    bands: [-2, 0, 4, 3, 0],
  );

  static const bright = EqPreset(
    id: 'bright',
    name: 'Bright',
    bands: [0, 0, 2, 4, 6],
  );

  static List<EqPreset> get all => [flat, bassBoost, vocal, bright];

  static EqPreset? byId(String id) {
    for (final p in all) {
      if (p.id == id) return p;
    }
    return null;
  }
}
