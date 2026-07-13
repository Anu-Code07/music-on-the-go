import '../../../library/domain/entities/track.dart';
import '../../domain/repositories/discover_repository.dart';

class GetPopularDiscover {
  GetPopularDiscover(this._repository);
  final DiscoverRepository _repository;
  Future<List<Track>> call() => _repository.getPopular();
}
