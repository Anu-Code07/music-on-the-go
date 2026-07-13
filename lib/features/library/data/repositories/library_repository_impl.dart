import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/track.dart';
import '../../domain/repositories/library_repository.dart';
import '../datasources/local_library_data_source.dart';
import '../datasources/seed_library_bootstrap.dart';

class LibraryRepositoryImpl implements LibraryRepository {
  LibraryRepositoryImpl(this._local, this._bootstrap);

  final LocalLibraryDataSource _local;
  final SeedLibraryBootstrap _bootstrap;
  static const _uuid = Uuid();

  @override
  Future<List<Track>> getTracks() => _local.getAllTracks();

  @override
  Future<List<Track>> getLiked() => _local.getLikedTracks();

  @override
  Future<List<Track>> getRecents({int limit = 20}) =>
      _local.getRecents(limit: limit);

  @override
  Future<Track?> getTrack(String id) => _local.getTrack(id);

  @override
  Future<void> upsertTrack(Track track) => _local.upsertTrack(track);

  @override
  Future<void> toggleLike(String id) async {
    final track = await _local.getTrack(id);
    if (track == null) throw Failure('Track not found');
    await _local.setLiked(id, !track.isLiked);
  }

  @override
  Future<Track> importFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'm4a', 'wav', 'aac', 'flac', 'ogg'],
    );
    if (result == null || result.files.isEmpty) {
      throw Failure('Import cancelled');
    }
    final picked = result.files.first;
    final sourcePath = picked.path;
    if (sourcePath == null) throw Failure('Could not read file path');

    final docs = await getApplicationDocumentsDirectory();
    final musicDir = Directory(p.join(docs.path, 'music'));
    if (!await musicDir.exists()) await musicDir.create(recursive: true);

    final id = _uuid.v4();
    final ext = p.extension(sourcePath);
    final destPath = p.join(musicDir.path, '$id$ext');
    await File(sourcePath).copy(destPath);

    final track = Track(
      id: id,
      title: p.basenameWithoutExtension(sourcePath),
      artist: 'Imported',
      filePath: destPath,
      durationMs: 0,
      isLocal: true,
      source: TrackSource.imported,
    );
    await _local.upsertTrack(track);
    return track;
  }

  @override
  Future<void> deleteTrack(String id) async {
    final track = await _local.getTrack(id);
    if (track?.filePath != null) {
      final file = File(track!.filePath!);
      if (await file.exists()) await file.delete();
    }
    if (track?.artworkPath != null) {
      final art = File(track!.artworkPath!);
      if (await art.exists()) await art.delete();
    }
    await _local.deleteTrack(id);
  }

  @override
  Future<void> ensureSeeded() => _bootstrap.ensureSeeded();

  @override
  Future<void> addRecent(String trackId) => _local.addRecent(trackId);
}
