import '../../../library/domain/entities/track.dart';
import '../../../library/domain/repositories/library_repository.dart';
import '../../data/datasources/audio_player_data_source.dart';

class PlayTrack {
  PlayTrack(this._player, this._library);

  final AudioPlayerDataSource _player;
  final LibraryRepository _library;

  Future<void> call(Track track, {List<Track>? queue, int index = 0}) async {
    // Persist stream/local metadata so recents JOIN works.
    await _library.upsertTrack(track);

    if (queue != null && queue.isNotEmpty) {
      await _player.playQueue(queue, index);
    } else {
      await _player.playTrack(track);
    }
    await _library.addRecent(track.id);
  }
}
