import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
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
    if (loaded == 'true') {
      final existing = await _local.getAllTracks();
      // Recover from a prior run that marked seeds done but inserted nothing.
      if (existing.isNotEmpty) return;
      debugPrint('Seed flag set but library empty — retrying seed');
    }

    final raw = await rootBundle.loadString('assets/seed/manifest.json');
    final entries = jsonDecode(raw) as List<dynamic>;

    final docs = await getApplicationDocumentsDirectory();
    final musicDir = Directory(p.join(docs.path, 'music'));
    if (!await musicDir.exists()) {
      await musicDir.create(recursive: true);
    }

    var seeded = 0;
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
          } catch (e) {
            debugPrint('Seed art skipped for $id: $e');
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
        seeded++;
      } catch (e, st) {
        debugPrint('Seed entry failed: $e\n$st');
      }
    }

    if (seeded > 0 || entries.isEmpty) {
      await _local.setSetting(_seedsLoadedKey, 'true');
    } else {
      debugPrint('Seed inserted 0 tracks — will retry next launch');
    }
  }
}
