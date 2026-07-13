import '../../../library/domain/entities/track.dart';
import '../../domain/repositories/discover_repository.dart';

class SearchDiscover {
  SearchDiscover(this._repository);
  final DiscoverRepository _repository;
  Future<List<Track>> call(String query) => _repository.search(query);
}
