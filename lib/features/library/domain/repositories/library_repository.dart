import '../entities/track.dart';

abstract class LibraryRepository {
  Future<List<Track>> getTracks();
  Future<List<Track>> getLiked();
  Future<List<Track>> getRecents({int limit});
  Future<Track?> getTrack(String id);
  Future<void> upsertTrack(Track track);
  Future<void> toggleLike(String id);
  Future<Track> importFile();
  Future<void> deleteTrack(String id);
  Future<void> ensureSeeded();
  Future<void> addRecent(String trackId);
}
