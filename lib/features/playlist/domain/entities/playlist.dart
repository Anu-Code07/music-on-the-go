import 'package:equatable/equatable.dart';

import '../../../library/domain/entities/track.dart';

class Playlist extends Equatable {
  const Playlist({
    required this.id,
    required this.name,
    this.trackIds = const [],
    this.createdAt,
  });

  final String id;
  final String name;
  final List<String> trackIds;
  final DateTime? createdAt;

  Playlist copyWith({
    String? id,
    String? name,
    List<String>? trackIds,
    DateTime? createdAt,
  }) {
    return Playlist(
      id: id ?? this.id,
      name: name ?? this.name,
      trackIds: trackIds ?? this.trackIds,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, name, trackIds, createdAt];
}

class PlaylistWithTracks extends Equatable {
  const PlaylistWithTracks({
    required this.playlist,
    required this.tracks,
  });

  final Playlist playlist;
  final List<Track> tracks;

  @override
  List<Object?> get props => [playlist, tracks];
}
