import 'dart:io';

import 'package:just_audio/just_audio.dart';

import '../../../library/data/datasources/local_library_data_source.dart';
import '../../domain/entities/eq_preset.dart';

class EqualizerDataSource {
  EqualizerDataSource(this._local, this._equalizer);

  final LocalLibraryDataSource _local;
  final AndroidEqualizer? _equalizer;
  EqPreset _current = EqPresets.flat;

  EqPreset get currentPreset => _current;

  Future<void> init() async {
    if (_equalizer != null) {
      try {
        await _equalizer.setEnabled(true);
      } catch (_) {}
    }
    await loadSavedPreset();
  }

  Future<void> loadSavedPreset() async {
    final id = await _local.getSetting(_presetKey);
    _current = EqPresets.byId(id ?? '') ?? EqPresets.flat;
    final json = await _local.getJsonSetting(_bandsKey);
    if (json != null) {
      final bands = (json['bands'] as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList();
      if (bands != null && bands.length == 5) {
        _current = EqPreset(id: _current.id, name: _current.name, bands: bands);
      }
    }
    await applyPreset(_current);
  }

  static const _presetKey = 'eq_preset';
  static const _bandsKey = 'eq_bands';

  Future<void> applyPreset(EqPreset preset) async {
    _current = preset;
    await _local.setSetting(_presetKey, preset.id);
    await _local.setJsonSetting(_bandsKey, {'bands': preset.bands});

    final eq = _equalizer;
    if (eq != null && Platform.isAndroid) {
      try {
        final params = await eq.parameters;
        for (var i = 0; i < params.bands.length && i < preset.bands.length; i++) {
          final gain = preset.bands[i].clamp(params.minDecibels, params.maxDecibels);
          await params.bands[i].setGain(gain);
        }
      } catch (_) {}
    }
  }

  List<double> get currentBands => List.of(_current.bands);
}
