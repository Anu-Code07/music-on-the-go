import 'dart:convert';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../../domain/entities/track.dart';
import '../../../playlist/domain/entities/playlist.dart';

class LocalLibraryDataSource {
  Database? _db;
  Future<Database>? _openFuture;

  Future<Database> get database async {
    if (_db != null) return _db!;
    // Serialize first open — seed + Library + Playlists used to race and
    // throw SQLITE_BUSY on PRAGMA journal_mode.
    _openFuture ??= () async {
      try {
        final db = await _open();
        _db = db;
        return db;
      } catch (e) {
        _openFuture = null;
        rethrow;
      }
    }();
    return _openFuture!;
  }

  Future<Database> _open() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, 'studio.db');
    try {
      return await _openAt(path);
    } catch (e) {
      // Recover from a broken/partial open (common after pragma failures).
      await deleteDatabase(path);
      return _openAt(path);
    }
  }

  Future<Database> _openAt(String path) {
    return openDatabase(
      path,
      version: 1,
      singleInstance: true,
      onConfigure: (db) async {
        // Darwin throws DatabaseException("not an error") for some PRAGMAs
        // when using execute(); rawQuery is required. Never fail open on this.
        try {
          await db.rawQuery('PRAGMA busy_timeout=5000');
        } catch (_) {}
        try {
          await db.rawQuery('PRAGMA journal_mode=WAL');
        } catch (_) {}
      },
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE tracks (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            artist TEXT NOT NULL,
            album TEXT NOT NULL DEFAULT '',
            duration_ms INTEGER NOT NULL DEFAULT 0,
            file_path TEXT,
            artwork_url TEXT,
            artwork_path TEXT,
            stream_url TEXT,
            jamendo_id TEXT,
            is_liked INTEGER NOT NULL DEFAULT 0,
            is_local INTEGER NOT NULL DEFAULT 1,
            source TEXT NOT NULL DEFAULT 'local',
            created_at INTEGER NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE playlists (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            created_at INTEGER NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE playlist_tracks (
            playlist_id TEXT NOT NULL,
            track_id TEXT NOT NULL,
            position INTEGER NOT NULL DEFAULT 0,
            PRIMARY KEY (playlist_id, track_id)
          )
        ''');
        await db.execute('''
          CREATE TABLE recents (
            track_id TEXT PRIMARY KEY,
            played_at INTEGER NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE settings (
            key TEXT PRIMARY KEY,
            value TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<void> upsertTrack(Track track) async {
    final db = await database;
    final rows = await db.query(
      'tracks',
      where: 'id = ?',
      whereArgs: [track.id],
    );

    if (rows.isEmpty) {
      await db.insert('tracks', _trackToMap(track));
      return;
    }

    // Merge instead of REPLACE — playing a Discover stream track must not
    // wipe file_path, likes, artwork, or is_local from a prior Save.
    final existing = _trackFromMap(rows.first);
    final createdAt = rows.first['created_at'] as int;
    final merged = _mergeTrack(existing, track);
    await db.update(
      'tracks',
      _trackToMap(merged, createdAtMs: createdAt),
      where: 'id = ?',
      whereArgs: [track.id],
    );
  }

  Track _mergeTrack(Track existing, Track incoming) {
    final filePath = _preferNonEmpty(incoming.filePath, existing.filePath);
    final artworkPath =
        _preferNonEmpty(incoming.artworkPath, existing.artworkPath);
    return Track(
      id: existing.id,
      title: incoming.title.isNotEmpty ? incoming.title : existing.title,
      artist: incoming.artist.isNotEmpty ? incoming.artist : existing.artist,
      album: incoming.album.isNotEmpty ? incoming.album : existing.album,
      durationMs:
          incoming.durationMs > 0 ? incoming.durationMs : existing.durationMs,
      filePath: filePath,
      artworkUrl: _preferNonEmpty(incoming.artworkUrl, existing.artworkUrl),
      artworkPath: artworkPath,
      streamUrl: _preferNonEmpty(incoming.streamUrl, existing.streamUrl),
      jamendoId: _preferNonEmpty(incoming.jamendoId, existing.jamendoId),
      // Likes are toggled via setLiked — never clear via a thin stream upsert.
      isLiked: existing.isLiked || incoming.isLiked,
      isLocal: existing.isLocal ||
          incoming.isLocal ||
          (filePath != null && filePath.isNotEmpty),
      source: (filePath != null && filePath.isNotEmpty && !incoming.isLocal)
          ? existing.source
          : incoming.source,
    );
  }

  String? _preferNonEmpty(String? preferred, String? fallback) {
    if (preferred != null && preferred.isNotEmpty) return preferred;
    if (fallback != null && fallback.isNotEmpty) return fallback;
    return preferred ?? fallback;
  }

  Future<List<Track>> getAllTracks() async {
    final db = await database;
    final rows = await db.query('tracks', orderBy: 'created_at DESC');
    return rows.map(_trackFromMap).toList();
  }

  Future<Track?> getTrack(String id) async {
    final db = await database;
    final rows = await db.query('tracks', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return _trackFromMap(rows.first);
  }

  Future<void> deleteTrack(String id) async {
    final db = await database;
    await db.delete('tracks', where: 'id = ?', whereArgs: [id]);
    await db.delete('playlist_tracks', where: 'track_id = ?', whereArgs: [id]);
    await db.delete('recents', where: 'track_id = ?', whereArgs: [id]);
  }

  Future<void> setLiked(String id, bool liked) async {
    final db = await database;
    await db.update(
      'tracks',
      {'is_liked': liked ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Track>> getLikedTracks() async {
    final db = await database;
    final rows = await db.query(
      'tracks',
      where: 'is_liked = 1',
      orderBy: 'created_at DESC',
    );
    return rows.map(_trackFromMap).toList();
  }

  Future<void> addRecent(String trackId) async {
    final db = await database;
    await db.insert(
      'recents',
      {
        'track_id': trackId,
        'played_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Track>> getRecents({int limit = 20}) async {
    final db = await database;
    final rows = await db.rawQuery('''
      SELECT t.* FROM recents r
      INNER JOIN tracks t ON t.id = r.track_id
      ORDER BY r.played_at DESC
      LIMIT ?
    ''', [limit]);
    return rows.map(_trackFromMap).toList();
  }

  Future<void> createPlaylist(Playlist playlist) async {
    final db = await database;
    await db.insert('playlists', {
      'id': playlist.id,
      'name': playlist.name,
      'created_at':
          (playlist.createdAt ?? DateTime.now()).millisecondsSinceEpoch,
    });
  }

  Future<void> renamePlaylist(String id, String name) async {
    final db = await database;
    await db.update(
      'playlists',
      {'name': name},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deletePlaylist(String id) async {
    final db = await database;
    await db.delete('playlist_tracks', where: 'playlist_id = ?', whereArgs: [id]);
    await db.delete('playlists', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Playlist>> getPlaylists() async {
    final db = await database;
    final rows = await db.query('playlists', orderBy: 'created_at DESC');
    final result = <Playlist>[];
    for (final row in rows) {
      final ids = await db.query(
        'playlist_tracks',
        columns: ['track_id'],
        where: 'playlist_id = ?',
        whereArgs: [row['id']],
        orderBy: 'position ASC',
      );
      result.add(
        Playlist(
          id: row['id'] as String,
          name: row['name'] as String,
          trackIds: ids.map((e) => e['track_id'] as String).toList(),
          createdAt: DateTime.fromMillisecondsSinceEpoch(
            row['created_at'] as int,
          ),
        ),
      );
    }
    return result;
  }

  Future<void> addTrackToPlaylist(String playlistId, String trackId) async {
    final db = await database;
    final count = Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM playlist_tracks WHERE playlist_id = ?',
            [playlistId],
          ),
        ) ??
        0;
    await db.insert(
      'playlist_tracks',
      {
        'playlist_id': playlistId,
        'track_id': trackId,
        'position': count,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> removeTrackFromPlaylist(String playlistId, String trackId) async {
    final db = await database;
    await db.delete(
      'playlist_tracks',
      where: 'playlist_id = ? AND track_id = ?',
      whereArgs: [playlistId, trackId],
    );
  }

  Future<void> setSetting(String key, String value) async {
    final db = await database;
    await db.insert(
      'settings',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> getSetting(String key) async {
    final db = await database;
    final rows = await db.query(
      'settings',
      where: 'key = ?',
      whereArgs: [key],
    );
    if (rows.isEmpty) return null;
    return rows.first['value'] as String;
  }

  Future<Map<String, dynamic>?> getJsonSetting(String key) async {
    final raw = await getSetting(key);
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<void> setJsonSetting(String key, Map<String, dynamic> value) async {
    await setSetting(key, jsonEncode(value));
  }

  Map<String, Object?> _trackToMap(Track track, {int? createdAtMs}) {
    return {
      'id': track.id,
      'title': track.title,
      'artist': track.artist,
      'album': track.album,
      'duration_ms': track.durationMs,
      'file_path': track.filePath,
      'artwork_url': track.artworkUrl,
      'artwork_path': track.artworkPath,
      'stream_url': track.streamUrl,
      'jamendo_id': track.jamendoId,
      'is_liked': track.isLiked ? 1 : 0,
      'is_local': track.isLocal ? 1 : 0,
      'source': track.source.name,
      'created_at': createdAtMs ?? DateTime.now().millisecondsSinceEpoch,
    };
  }

  Track _trackFromMap(Map<String, Object?> map) {
    return Track(
      id: map['id'] as String,
      title: map['title'] as String,
      artist: map['artist'] as String,
      album: (map['album'] as String?) ?? '',
      durationMs: (map['duration_ms'] as int?) ?? 0,
      filePath: map['file_path'] as String?,
      artworkUrl: map['artwork_url'] as String?,
      artworkPath: map['artwork_path'] as String?,
      streamUrl: map['stream_url'] as String?,
      jamendoId: map['jamendo_id'] as String?,
      isLiked: (map['is_liked'] as int?) == 1,
      isLocal: (map['is_local'] as int?) != 0,
      source: TrackSource.values.firstWhere(
        (e) => e.name == map['source'],
        orElse: () => TrackSource.local,
      ),
    );
  }
}
