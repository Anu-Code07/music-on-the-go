import '../../../library/data/datasources/local_library_data_source.dart';
import '../../../library/domain/entities/track.dart';
import '../../domain/repositories/discover_repository.dart';
import '../datasources/jamendo_data_source.dart';
import '../datasources/theaudiodb_data_source.dart';

class DiscoverRepositoryImpl implements DiscoverRepository {
  DiscoverRepositoryImpl(
    this._jamendo,
    this._audioDb,
    this._local,
  );

  final JamendoDataSource _jamendo;
  final TheAudioDbDataSource _audioDb;
  final LocalLibraryDataSource _local;

  @override
  Future<List<Track>> search(String query) => _jamendo.searchTracks(query);

  @override
  Future<List<Track>> getPopular() => _jamendo.getPopularTracks();

  @override
  Future<Track> saveTrack(
    Track track, {
    void Function(double progress)? onProgress,
  }) async {
    onProgress?.call(0.1);
    var saved = await _jamendo.downloadTrack(track);
    onProgress?.call(0.7);

    final artUrl = await _audioDb.searchArtist(saved.artist);
    if (artUrl != null && (saved.artworkUrl == null || saved.artworkUrl!.isEmpty)) {
      saved = saved.copyWith(artworkUrl: artUrl);
    }
    onProgress?.call(0.9);

    await _local.upsertTrack(saved);
    onProgress?.call(1.0);
    return saved;
  }
}
