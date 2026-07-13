import '../../domain/repositories/library_repository.dart';

class ToggleLike {
  ToggleLike(this._repository);
  final LibraryRepository _repository;
  Future<void> call(String id) => _repository.toggleLike(id);
}
