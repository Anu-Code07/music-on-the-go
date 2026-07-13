import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../domain/entities/track.dart';
import 'local_library_data_source.dart';

class SeedLibraryBootstrap {
  SeedLibraryBootstrap(this._local);

  final LocalLibraryDataSource _local;
  static const _seedsLoadedKey = 'seeds_loaded';

  Future<void> ensureSeeded() async {
    final loaded = await _local.getSetting(_seedsLoadedKey);
    if (loaded == 'true') return;

    final raw = await rootBundle.loadString('assets/seed/manifest.json');
    final entries = jsonDecode(raw) as List<dynamic>;

    final docs = await getApplicationDocumentsDirectory();
    final musicDir = Directory(p.join(docs.path, 'music'));
    if (!await musicDir.exists()) {
      await musicDir.create(recursive: true);
    }

    for (final entry in entries) {
      try {
        final map = entry as Map<String, dynamic>;
        final id = map['id'] as String;
        final audioAsset = map['audioAsset'] as String?;
        if (audioAsset == null || audioAsset.isEmpty) continue;

        final bytes = await rootBundle.load(audioAsset);
        final audioPath = p.join(musicDir.path, '$id.mp3');
        await File(audioPath).writeAsBytes(
          bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
        );

        String? artPath;
        final artAsset = map['artAsset'] as String?;
        if (artAsset != null && artAsset.isNotEmpty) {
          try {
            final artBytes = await rootBundle.load(artAsset);
            artPath = p.join(musicDir.path, '$id.jpg');
            await File(artPath).writeAsBytes(
              artBytes.buffer
                  .asUint8List(artBytes.offsetInBytes, artBytes.lengthInBytes),
            );
          } catch (_) {
            artPath = null;
          }
        }

        final track = Track(
          id: id,
          title: map['title'] as String? ?? 'Untitled',
          artist: map['artist'] as String? ?? 'Unknown',
          album: map['album'] as String? ?? '',
          durationMs: (map['durationMs'] as num?)?.toInt() ?? 0,
          filePath: audioPath,
          artworkPath: artPath,
          jamendoId: map['jamendoId'] as String?,
          isLocal: true,
          source: TrackSource.seed,
        );
        await _local.upsertTrack(track);
      } catch (_) {
        // Skip missing or invalid seed entries.
      }
    }

    await _local.setSetting(_seedsLoadedKey, 'true');
  }
}
