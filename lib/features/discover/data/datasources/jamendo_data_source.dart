import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/config/api_keys.dart';
import '../../../library/domain/entities/track.dart';

class JamendoDataSource {
  JamendoDataSource({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;
  static const _uuid = Uuid();

  Future<List<Track>> searchTracks(String query) async {
    if (query.trim().isEmpty) return [];
    final response = await _dio.get<Map<String, dynamic>>(
      '${ApiKeys.jamendoBaseUrl}/tracks/',
      queryParameters: {
        'client_id': ApiKeys.jamendoClientId,
        'format': 'json',
        'limit': 30,
        // Jamendo v3: `search` returns empty for some clients; use namesearch.
        'namesearch': query.trim(),
        'include': 'musicinfo',
        'audioformat': 'mp32',
        'audiodlformat': 'mp32',
      },
    );
    return _parseTracks(response.data);
  }

  Future<List<Track>> getPopularTracks() async {
    // Prefer total popularity. Some order values (e.g. popularity_month,
    // featured) intermittently return 0 for this client_id.
    Future<List<Track>> fetch(String order) async {
      final response = await _dio.get<Map<String, dynamic>>(
        '${ApiKeys.jamendoBaseUrl}/tracks/',
        queryParameters: {
          'client_id': ApiKeys.jamendoClientId,
          'format': 'json',
          'limit': 30,
          'order': order,
          'include': 'musicinfo',
          'audioformat': 'mp32',
          'audiodlformat': 'mp32',
        },
      );
      return _parseTracks(response.data);
    }

    try {
      final tracks = await fetch('popularity_total');
      if (tracks.isNotEmpty) return tracks;
    } catch (_) {}

    return fetch('buzzrate');
  }

  Future<Track> downloadTrack(
    Track track, {
    void Function(double progress)? onProgress,
  }) async {
    final jamendoId = track.jamendoId;
    final downloadUrl = (jamendoId != null && jamendoId.isNotEmpty)
        ? '${ApiKeys.jamendoBaseUrl}/tracks/file/'
            '?client_id=${ApiKeys.jamendoClientId}'
            '&id=$jamendoId'
            '&audioformat=mp32'
            '&action=download'
        : track.streamUrl;
    if (downloadUrl == null || downloadUrl.isEmpty) {
      throw Exception('Track has no download URL');
    }

    final musicDir = await _musicDirectory();
    final id = jamendoId ??
        track.id.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    final audioPath = p.join(musicDir.path, '$id.mp3');
    final artPath = p.join(musicDir.path, '$id.jpg');

    onProgress?.call(0.02);
    try {
      await _dio.download(
        downloadUrl,
        audioPath,
        onReceiveProgress: (received, total) {
          if (total <= 0) return;
          // Reserve 0.02–0.85 for the audio file download.
          final ratio = (received / total).clamp(0.0, 1.0);
          onProgress?.call(0.02 + (ratio * 0.83));
        },
        options: Options(
          followRedirects: true,
          maxRedirects: 5,
          validateStatus: (s) => s != null && s < 400,
          receiveTimeout: const Duration(minutes: 3),
          sendTimeout: const Duration(seconds: 30),
          headers: const {
            'Accept': '*/*',
            'User-Agent': 'Aria/1.0 (iOS; music-on-the-go)',
          },
        ),
      );
    } on DioException catch (e) {
      throw Exception('Download failed: ${e.message ?? e.type.name}');
    }

    final file = File(audioPath);
    if (!await file.exists() || await file.length() < 1024) {
      throw Exception('Downloaded file is empty or too small');
    }
    onProgress?.call(0.88);

    String? savedArtPath;
    final artUrl = track.artworkUrl;
    if (artUrl != null && artUrl.isNotEmpty) {
      try {
        await _dio.download(artUrl, artPath);
        savedArtPath = artPath;
      } catch (_) {
        savedArtPath = null;
      }
    }
    onProgress?.call(0.95);

    return track.copyWith(
      id: jamendoId != null ? 'jamendo_$jamendoId' : track.id,
      filePath: audioPath,
      artworkPath: savedArtPath ?? track.artworkPath,
      isLocal: true,
      source: TrackSource.jamendo,
    );
  }

  List<Track> _parseTracks(Map<String, dynamic>? data) {
    if (data == null) return [];
    final results = data['results'] as List<dynamic>? ?? [];
    return results.map((raw) => _mapTrack(raw as Map<String, dynamic>)).toList();
  }

  Track _mapTrack(Map<String, dynamic> json) {
    final jamendoId = json['id']?.toString() ?? '';
    final artistName = json['artist_name'] as String? ?? 'Unknown';
    final albumName = json['album_name'] as String? ?? '';
    final image = json['image'] as String? ?? json['album_image'] as String?;
    final audio = json['audio'] as String? ?? '';
    final downloadAllowed = json['audiodownload_allowed'] == true;
    final audiodownload =
        downloadAllowed ? json['audiodownload'] as String? : null;
    final durationSec = (json['duration'] as num?)?.toDouble() ?? 0;

    return Track(
      id: 'jamendo_$jamendoId',
      title: json['name'] as String? ?? 'Untitled',
      artist: artistName,
      album: albumName,
      durationMs: (durationSec * 1000).round(),
      // Prefer download URL for Save; fall back to stream for playback.
      streamUrl: audiodownload ?? audio,
      artworkUrl: image,
      jamendoId: jamendoId,
      isLocal: false,
      source: TrackSource.jamendo,
    );
  }

  Future<Directory> _musicDirectory() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, 'music'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  String newLocalId() => _uuid.v4();
}
