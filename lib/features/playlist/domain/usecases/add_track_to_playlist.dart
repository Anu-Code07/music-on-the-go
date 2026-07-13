import '../../domain/repositories/playlist_repository.dart';

class AddTrackToPlaylist {
  AddTrackToPlaylist(this._repository);
  final PlaylistRepository _repository;
  Future<void> call(String playlistId, String trackId) =>
      _repository.addTrack(playlistId, trackId);
}
