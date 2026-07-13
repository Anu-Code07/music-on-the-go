import 'package:dio/dio.dart';

import '../../../../core/config/api_keys.dart';

class TheAudioDbDataSource {
  TheAudioDbDataSource({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;
  final Map<String, String?> _cache = {};

  Future<String?> searchArtist(String name) async {
    final key = name.trim().toLowerCase();
    if (key.isEmpty) return null;
    if (_cache.containsKey(key)) return _cache[key];

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '${ApiKeys.theAudioDbBaseUrl}/${ApiKeys.theAudioDbKey}/search.php',
        queryParameters: {'s': name.trim()},
      );
      final artists = response.data?['artists'] as List<dynamic>?;
      if (artists == null || artists.isEmpty) {
        _cache[key] = null;
        return null;
      }
      final first = artists.first as Map<String, dynamic>?;
      final thumb = first?['strArtistThumb'] as String?;
      final banner = first?['strArtistBanner'] as String?;
      final url = (thumb != null && thumb.isNotEmpty)
          ? thumb
          : (banner != null && banner.isNotEmpty ? banner : null);
      _cache[key] = url;
      return url;
    } catch (_) {
      _cache[key] = null;
      return null;
    }
  }
}
