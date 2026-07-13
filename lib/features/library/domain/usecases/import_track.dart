import '../../domain/entities/track.dart';
import '../../domain/repositories/library_repository.dart';

class ImportTrack {
  ImportTrack(this._repository);
  final LibraryRepository _repository;
  Future<Track> call() => _repository.importFile();
}
