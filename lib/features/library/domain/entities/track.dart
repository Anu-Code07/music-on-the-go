import 'package:equatable/equatable.dart';

class Track extends Equatable {
  const Track({
    required this.id,
    required this.title,
    required this.artist,
    this.album = '',
    this.durationMs = 0,
    this.filePath,
    this.artworkUrl,
    this.artworkPath,
    this.streamUrl,
    this.jamendoId,
    this.isLiked = false,
    this.isLocal = true,
    this.source = TrackSource.local,
  });

  final String id;
  final String title;
  final String artist;
  final String album;
  final int durationMs;
  final String? filePath;
  final String? artworkUrl;
  final String? artworkPath;
  final String? streamUrl;
  final String? jamendoId;
  final bool isLiked;
  final bool isLocal;
  final TrackSource source;

  bool get isPlayable =>
      (filePath != null && filePath!.isNotEmpty) ||
      (streamUrl != null && streamUrl!.isNotEmpty);

  Track copyWith({
    String? id,
    String? title,
    String? artist,
    String? album,
    int? durationMs,
    String? filePath,
    String? artworkUrl,
    String? artworkPath,
    String? streamUrl,
    String? jamendoId,
    bool? isLiked,
    bool? isLocal,
    TrackSource? source,
  }) {
    return Track(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      durationMs: durationMs ?? this.durationMs,
      filePath: filePath ?? this.filePath,
      artworkUrl: artworkUrl ?? this.artworkUrl,
      artworkPath: artworkPath ?? this.artworkPath,
      streamUrl: streamUrl ?? this.streamUrl,
      jamendoId: jamendoId ?? this.jamendoId,
      isLiked: isLiked ?? this.isLiked,
      isLocal: isLocal ?? this.isLocal,
      source: source ?? this.source,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        artist,
        album,
        durationMs,
        filePath,
        artworkUrl,
        artworkPath,
        streamUrl,
        jamendoId,
        isLiked,
        isLocal,
        source,
      ];
}

enum TrackSource { local, jamendo, seed, imported }
