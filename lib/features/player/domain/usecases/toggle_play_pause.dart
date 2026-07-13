import '../../data/datasources/audio_player_data_source.dart';

class TogglePlayPause {
  TogglePlayPause(this._player);

  final AudioPlayerDataSource _player;

  Future<void> call({required bool isPlaying}) async {
    if (isPlaying) {
      await _player.pause();
    } else {
      await _player.resume();
    }
  }
}
