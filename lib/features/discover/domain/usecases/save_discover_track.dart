import '../../../library/domain/entities/track.dart';
import '../../domain/repositories/discover_repository.dart';

class SaveDiscoverTrack {
  SaveDiscoverTrack(this._repository);
  final DiscoverRepository _repository;
  Future<Track> call(
    Track track, {
    void Function(double progress)? onProgress,
  }) =>
      _repository.saveTrack(track, onProgress: onProgress);
}
