import '../../domain/repositories/library_repository.dart';

class EnsureSeedLibrary {
  EnsureSeedLibrary(this._repository);
  final LibraryRepository _repository;
  Future<void> call() => _repository.ensureSeeded();
}
