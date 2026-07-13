import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/datasources/equalizer_data_source.dart';
import '../../domain/entities/eq_preset.dart';

sealed class EqualizerState extends Equatable {
  const EqualizerState();
  @override
  List<Object?> get props => [];
}

final class EqualizerInitial extends EqualizerState {
  const EqualizerInitial();
}

final class EqualizerReady extends EqualizerState {
  const EqualizerReady({
    required this.presets,
    required this.selected,
    required this.bands,
  });

  final List<EqPreset> presets;
  final EqPreset selected;
  final List<double> bands;

  @override
  List<Object?> get props => [presets, selected, bands];
}

sealed class EqualizerEvent extends Equatable {
  const EqualizerEvent();
  @override
  List<Object?> get props => [];
}

final class LoadPresets extends EqualizerEvent {
  const LoadPresets();
}

final class SelectPreset extends EqualizerEvent {
  const SelectPreset(this.preset);
  final EqPreset preset;
  @override
  List<Object?> get props => [preset];
}

class EqualizerBloc extends Bloc<EqualizerEvent, EqualizerState> {
  EqualizerBloc(this._dataSource) : super(const EqualizerInitial()) {
    on<LoadPresets>(_onLoad);
    on<SelectPreset>(_onSelect);
  }

  final EqualizerDataSource _dataSource;

  Future<void> _onLoad(LoadPresets event, Emitter<EqualizerState> emit) async {
    await _dataSource.loadSavedPreset();
    emit(EqualizerReady(
      presets: EqPresets.all,
      selected: _dataSource.currentPreset,
      bands: _dataSource.currentBands,
    ));
  }

  Future<void> _onSelect(
      SelectPreset event, Emitter<EqualizerState> emit) async {
    await _dataSource.applyPreset(event.preset);
    emit(EqualizerReady(
      presets: EqPresets.all,
      selected: event.preset,
      bands: _dataSource.currentBands,
    ));
  }
}
