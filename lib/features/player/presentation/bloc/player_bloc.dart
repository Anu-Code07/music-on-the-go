import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';

import '../../../library/domain/entities/track.dart';
import '../../../library/domain/repositories/library_repository.dart';
import '../../../library/domain/usecases/toggle_like.dart';
import '../../data/datasources/audio_player_data_source.dart';
import '../../data/datasources/widget_bridge_data_source.dart';
import '../../domain/usecases/play_track.dart';
import '../../domain/usecases/toggle_play_pause.dart';

sealed class PlayerState extends Equatable {
  const PlayerState();
  @override
  List<Object?> get props => [];
}

final class PlayerInitial extends PlayerState {
  const PlayerInitial();
}

final class PlayerReady extends PlayerState {
  const PlayerReady({
    required this.track,
    required this.queue,
    required this.isPlaying,
    required this.position,
    required this.duration,
    required this.shuffle,
    required this.repeat,
    required this.isLiked,
    this.currentIndex = 0,
  });

  final Track? track;
  final List<Track> queue;
  final bool isPlaying;
  final Duration position;
  final Duration? duration;
  final bool shuffle;
  final LoopMode repeat;
  final bool isLiked;
  final int currentIndex;

  PlayerReady copyWith({
    Track? track,
    List<Track>? queue,
    bool? isPlaying,
    Duration? position,
    Duration? duration,
    bool? shuffle,
    LoopMode? repeat,
    bool? isLiked,
    int? currentIndex,
  }) {
    return PlayerReady(
      track: track ?? this.track,
      queue: queue ?? this.queue,
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      shuffle: shuffle ?? this.shuffle,
      repeat: repeat ?? this.repeat,
      isLiked: isLiked ?? this.isLiked,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }

  @override
  List<Object?> get props =>
      [track, queue, isPlaying, position, duration, shuffle, repeat, isLiked, currentIndex];
}

sealed class PlayerEvent extends Equatable {
  const PlayerEvent();
  @override
  List<Object?> get props => [];
}

final class LoadQueue extends PlayerEvent {
  const LoadQueue(this.tracks, {this.index = 0});
  final List<Track> tracks;
  final int index;
  @override
  List<Object?> get props => [tracks, index];
}

final class Play extends PlayerEvent {
  const Play(this.track);
  final Track track;
  @override
  List<Object?> get props => [track];
}

final class Pause extends PlayerEvent {
  const Pause();
}

final class Toggle extends PlayerEvent {
  const Toggle();
}

final class Seek extends PlayerEvent {
  const Seek(this.position);
  final Duration position;
  @override
  List<Object?> get props => [position];
}

final class Next extends PlayerEvent {
  const Next();
}

final class Previous extends PlayerEvent {
  const Previous();
}

final class ToggleShuffle extends PlayerEvent {
  const ToggleShuffle();
}

final class ToggleRepeat extends PlayerEvent {
  const ToggleRepeat();
}

final class ToggleLikeCurrent extends PlayerEvent {
  const ToggleLikeCurrent();
}

final class _PlayerTick extends PlayerEvent {
  const _PlayerTick({
    required this.position,
    required this.duration,
    required this.isPlaying,
    required this.index,
  });
  final Duration position;
  final Duration? duration;
  final bool isPlaying;
  final int? index;
  @override
  List<Object?> get props => [position, duration, isPlaying, index];
}

class PlayerBloc extends Bloc<PlayerEvent, PlayerState> {
  PlayerBloc({
    required AudioPlayerDataSource audio,
    required PlayTrack playTrack,
    required TogglePlayPause togglePlayPause,
    required ToggleLike toggleLike,
    required LibraryRepository library,
    required WidgetBridgeDataSource widgetBridge,
  })  : _audio = audio,
        _playTrack = playTrack,
        _togglePlayPause = togglePlayPause,
        _toggleLike = toggleLike,
        _library = library,
        _widgetBridge = widgetBridge,
        super(const PlayerInitial()) {
    on<LoadQueue>(_onLoadQueue);
    on<Play>(_onPlay);
    on<Pause>(_onPause);
    on<Toggle>(_onToggle);
    on<Seek>(_onSeek);
    on<Next>(_onNext);
    on<Previous>(_onPrevious);
    on<ToggleShuffle>(_onToggleShuffle);
    on<ToggleRepeat>(_onToggleRepeat);
    on<ToggleLikeCurrent>(_onToggleLike);
    on<_PlayerTick>(_onTick);

    _audio.positionStream.listen((pos) => _emitTick());
    _audio.playingStream.listen((_) => _emitTick());
    _audio.currentIndexStream.listen((_) => _emitTick());
    _audio.durationStream.listen((_) => _emitTick());
  }

  final AudioPlayerDataSource _audio;
  final PlayTrack _playTrack;
  final TogglePlayPause _togglePlayPause;
  final ToggleLike _toggleLike;
  final LibraryRepository _library;
  final WidgetBridgeDataSource _widgetBridge;

  bool _shuffle = false;
  LoopMode _repeat = LoopMode.off;

  PlayerReady get _ready => state is PlayerReady
      ? state as PlayerReady
      : const PlayerReady(
          track: null,
          queue: [],
          isPlaying: false,
          position: Duration.zero,
          duration: null,
          shuffle: false,
          repeat: LoopMode.off,
          isLiked: false,
        );

  void _emitTick() {
    add(_PlayerTick(
      position: _audio.player.position,
      duration: _audio.player.duration,
      isPlaying: _audio.player.playing,
      index: _audio.player.currentIndex,
    ));
  }

  Future<void> _onLoadQueue(LoadQueue event, Emitter<PlayerState> emit) async {
    if (event.tracks.isEmpty) return;
    try {
      final idx = event.index.clamp(0, event.tracks.length - 1);
      await _playTrack(event.tracks[idx], queue: event.tracks, index: idx);
      await _syncState(emit);
    } catch (e) {
      debugPrint('LoadQueue failed: $e');
      await _syncState(emit);
    }
  }

  Future<void> _onPlay(Play event, Emitter<PlayerState> emit) async {
    try {
      if (!event.track.isPlayable) {
        debugPrint('Track not playable: ${event.track.id}');
        return;
      }
      await _playTrack(event.track);
      await _syncState(emit);
    } catch (e) {
      debugPrint('Play failed: $e');
      await _syncState(emit);
    }
  }

  Future<void> _onPause(Pause event, Emitter<PlayerState> emit) async {
    await _togglePlayPause(isPlaying: true);
    emit(_ready.copyWith(isPlaying: false));
    await _widgetBridge.updateNowPlaying(track: _ready.track, isPlaying: false, forceLive: true);
  }

  Future<void> _onToggle(Toggle event, Emitter<PlayerState> emit) async {
    final playing = _audio.player.playing;
    await _togglePlayPause(isPlaying: playing);
    emit(_ready.copyWith(isPlaying: !playing));
    await _widgetBridge.updateNowPlaying(
      track: _ready.track,
      isPlaying: !playing,
      forceLive: true,
    );
  }

  Future<void> _onSeek(Seek event, Emitter<PlayerState> emit) async {
    await _audio.seek(event.position);
    emit(_ready.copyWith(position: event.position));
  }

  Future<void> _onNext(Next event, Emitter<PlayerState> emit) async {
    await _audio.skipNext();
    _audio.syncIndexFromPlayer();
    await _syncState(emit);
  }

  Future<void> _onPrevious(Previous event, Emitter<PlayerState> emit) async {
    await _audio.skipPrevious();
    _audio.syncIndexFromPlayer();
    await _syncState(emit);
  }

  Future<void> _onToggleShuffle(
      ToggleShuffle event, Emitter<PlayerState> emit) async {
    _shuffle = !_shuffle;
    await _audio.setShuffle(_shuffle);
    emit(_ready.copyWith(shuffle: _shuffle));
  }

  Future<void> _onToggleRepeat(
      ToggleRepeat event, Emitter<PlayerState> emit) async {
    _repeat = switch (_repeat) {
      LoopMode.off => LoopMode.all,
      LoopMode.all => LoopMode.one,
      _ => LoopMode.off,
    };
    await _audio.setLoopMode(_repeat);
    emit(_ready.copyWith(repeat: _repeat));
  }

  Future<void> _onToggleLike(
      ToggleLikeCurrent event, Emitter<PlayerState> emit) async {
    final track = _ready.track;
    if (track == null) return;
    try {
      await _toggleLike(track.id);
      final updated = await _library.getTrack(track.id);
      emit(_ready.copyWith(
        track: updated ?? track,
        isLiked: updated?.isLiked ?? !track.isLiked,
      ));
    } catch (e) {
      debugPrint('Like failed (save track first?): $e');
    }
  }

  void _onTick(_PlayerTick event, Emitter<PlayerState> emit) {
    _audio.syncIndexFromPlayer();
    final track = _audio.currentTrack;
    if (track == null && _ready.track == null) return;
    emit(_ready.copyWith(
      track: track ?? _ready.track,
      queue: _audio.queue,
      isPlaying: event.isPlaying,
      position: event.position,
      duration: event.duration,
      shuffle: _shuffle,
      repeat: _repeat,
      currentIndex: event.index ?? _audio.currentIndex,
      isLiked: track?.isLiked ?? _ready.isLiked,
    ));
    // Throttled inside WidgetBridgeDataSource.
    // ignore: discarded_futures
    _widgetBridge.updateNowPlaying(
      track: track ?? _ready.track,
      isPlaying: event.isPlaying,
      position: event.position,
      duration: event.duration,
    );
  }

  Future<void> _syncState(Emitter<PlayerState> emit) async {
    final track = _audio.currentTrack;
    var liked = track?.isLiked ?? false;
    if (track != null) {
      final fresh = await _library.getTrack(track.id);
      liked = fresh?.isLiked ?? track.isLiked;
    }
    emit(PlayerReady(
      track: track,
      queue: _audio.queue,
      isPlaying: _audio.player.playing,
      position: _audio.player.position,
      duration: _audio.player.duration,
      shuffle: _shuffle,
      repeat: _repeat,
      isLiked: liked,
      currentIndex: _audio.currentIndex,
    ));
    await _widgetBridge.updateNowPlaying(
      track: track,
      isPlaying: _audio.player.playing,
      position: _audio.player.position,
      duration: _audio.player.duration,
      forceLive: true,
    );
  }
}
