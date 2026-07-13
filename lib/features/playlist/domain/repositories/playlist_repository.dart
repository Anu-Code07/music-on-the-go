import '../entities/playlist.dart';

abstract class PlaylistRepository {
  Future<List<Playlist>> getPlaylists();
  Future<Playlist> createPlaylist(String name);
  Future<void> deletePlaylist(String id);
  Future<void> renamePlaylist(String id, String name);
  Future<void> addTrack(String playlistId, String trackId);
  Future<void> removeTrack(String playlistId, String trackId);
}
