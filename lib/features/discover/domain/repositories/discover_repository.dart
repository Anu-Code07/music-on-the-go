import '../../../library/domain/entities/track.dart';

abstract class DiscoverRepository {
  Future<List<Track>> search(String query);
  Future<List<Track>> getPopular();
  Future<Track> saveTrack(Track track, {void Function(double progress)? onProgress});
}
