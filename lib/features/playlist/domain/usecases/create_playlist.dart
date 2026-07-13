import '../../domain/entities/playlist.dart';
import '../../domain/repositories/playlist_repository.dart';

class CreatePlaylist {
  CreatePlaylist(this._repository);
  final PlaylistRepository _repository;
  Future<Playlist> call(String name) => _repository.createPlaylist(name);
}
