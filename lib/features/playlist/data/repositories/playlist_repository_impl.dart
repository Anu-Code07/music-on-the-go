import 'package:uuid/uuid.dart';

import '../../domain/entities/playlist.dart';
import '../../domain/repositories/playlist_repository.dart';
import '../../../library/data/datasources/local_library_data_source.dart';

class PlaylistRepositoryImpl implements PlaylistRepository {
  PlaylistRepositoryImpl(this._local);

  final LocalLibraryDataSource _local;
  static const _uuid = Uuid();

  @override
  Future<List<Playlist>> getPlaylists() => _local.getPlaylists();

  @override
  Future<Playlist> createPlaylist(String name) async {
    final playlist = Playlist(
      id: _uuid.v4(),
      name: name.trim().isEmpty ? 'Playlist' : name.trim(),
      createdAt: DateTime.now(),
    );
    await _local.createPlaylist(playlist);
    return playlist;
  }

  @override
  Future<void> deletePlaylist(String id) => _local.deletePlaylist(id);

  @override
  Future<void> renamePlaylist(String id, String name) =>
      _local.renamePlaylist(id, name);

  @override
  Future<void> addTrack(String playlistId, String trackId) =>
      _local.addTrackToPlaylist(playlistId, trackId);

  @override
  Future<void> removeTrack(String playlistId, String trackId) =>
      _local.removeTrackFromPlaylist(playlistId, trackId);
}
