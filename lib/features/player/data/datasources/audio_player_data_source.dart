import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';

import '../../../library/domain/entities/track.dart';

class AudioPlayerDataSource {
  AudioPlayerDataSource(this._player);

  final AudioPlayer _player;
  List<Track> _queue = [];
  int _currentIndex = 0;

  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<bool> get playingStream => _player.playingStream;
  Stream<int?> get currentIndexStream =>
      _player.sequenceStateStream.map((s) => s?.currentIndex);
  Stream<SequenceState?> get sequenceStateStream => _player.sequenceStateStream;

  AudioPlayer get player => _player;
  List<Track> get queue => List.unmodifiable(_queue);
  int get currentIndex => _currentIndex;
  Track? get currentTrack =>
      _queue.isEmpty || _currentIndex >= _queue.length ? null : _queue[_currentIndex];

  Future<void> _prepareOutput() async {
    try {
      final session = await AudioSession.instance;
      await session.setActive(true);
    } catch (_) {}
    // Guard against a silent player (volume stuck at 0).
    if (_player.volume < 0.99) {
      await _player.setVolume(1.0);
    }
  }

  Future<void> playTrack(Track track) async {
    _queue = [track];
    _currentIndex = 0;
    await _prepareOutput();
    await _player.setAudioSource(_sourceForTrack(track));
    await _player.setVolume(1.0);
    await _player.play();
  }

  Future<void> playQueue(List<Track> tracks, int index) async {
    if (tracks.isEmpty) return;
    _queue = List.of(tracks);
    _currentIndex = index.clamp(0, tracks.length - 1);
    await _prepareOutput();
    final playlist = ConcatenatingAudioSource(
      children: tracks.map(_sourceForTrack).toList(),
    );
    await _player.setAudioSource(playlist, initialIndex: _currentIndex);
    await _player.setVolume(1.0);
    await _player.play();
  }

  Future<void> pause() => _player.pause();

  Future<void> resume() async {
    await _prepareOutput();
    await _player.play();
  }

  Future<void> seek(Duration position) => _player.seek(position);

  Future<void> skipNext() async {
    if (_queue.isEmpty) return;
    if (_currentIndex < _queue.length - 1) {
      _currentIndex++;
      await _player.seekToNext();
    }
  }

  Future<void> skipPrevious() async {
    if (_queue.isEmpty) return;
    if (_player.position.inSeconds > 3) {
      await _player.seek(Duration.zero);
      return;
    }
    if (_currentIndex > 0) {
      _currentIndex--;
      await _player.seekToPrevious();
    } else {
      await _player.seek(Duration.zero);
    }
  }

  Future<void> setShuffle(bool enabled) =>
      _player.setShuffleModeEnabled(enabled);

  Future<void> setLoopMode(LoopMode mode) => _player.setLoopMode(mode);

  Future<void> setSpeed(double speed) => _player.setSpeed(speed);

  AudioSource _sourceForTrack(Track track) {
    if (track.filePath != null && track.filePath!.isNotEmpty) {
      return AudioSource.file(track.filePath!);
    }
    if (track.streamUrl != null && track.streamUrl!.isNotEmpty) {
      return AudioSource.uri(Uri.parse(track.streamUrl!));
    }
    throw StateError('Track is not playable');
  }

  void syncIndexFromPlayer() {
    final idx = _player.currentIndex;
    if (idx != null) _currentIndex = idx;
  }

  Future<void> dispose() => _player.dispose();
}
