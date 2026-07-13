import '../../domain/entities/track.dart';
import '../../domain/repositories/library_repository.dart';

class GetTracks {
  GetTracks(this._repository);
  final LibraryRepository _repository;
  Future<List<Track>> call() => _repository.getTracks();
}
