import '../../domain/entities/playlist.dart';
import '../../domain/repositories/playlist_repository.dart';

class GetPlaylists {
  GetPlaylists(this._repository);
  final PlaylistRepository _repository;
  Future<List<Playlist>> call() => _repository.getPlaylists();
}
