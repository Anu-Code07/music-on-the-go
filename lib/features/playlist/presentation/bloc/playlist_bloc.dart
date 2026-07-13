import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/playlist.dart';
import '../../domain/repositories/playlist_repository.dart';
import '../../domain/usecases/add_track_to_playlist.dart';
import '../../domain/usecases/create_playlist.dart';
import '../../domain/usecases/get_playlists.dart';

sealed class PlaylistState extends Equatable {
  const PlaylistState();
  @override
  List<Object?> get props => [];
}

final class PlaylistInitial extends PlaylistState {
  const PlaylistInitial();
}

final class PlaylistLoading extends PlaylistState {
  const PlaylistLoading();
}

final class PlaylistLoaded extends PlaylistState {
  const PlaylistLoaded(this.playlists);
  final List<Playlist> playlists;
  @override
  List<Object?> get props => [playlists];
}

final class PlaylistError extends PlaylistState {
  const PlaylistError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

sealed class PlaylistEvent extends Equatable {
  const PlaylistEvent();
  @override
  List<Object?> get props => [];
}

final class LoadPlaylists extends PlaylistEvent {
  const LoadPlaylists();
}

final class Create extends PlaylistEvent {
  const Create(this.name);
  final String name;
  @override
  List<Object?> get props => [name];
}

final class Delete extends PlaylistEvent {
  const Delete(this.id);
  final String id;
  @override
  List<Object?> get props => [id];
}

final class AddTrack extends PlaylistEvent {
  const AddTrack(this.playlistId, this.trackId);
  final String playlistId;
  final String trackId;
  @override
  List<Object?> get props => [playlistId, trackId];
}

final class RemoveTrack extends PlaylistEvent {
  const RemoveTrack(this.playlistId, this.trackId);
  final String playlistId;
  final String trackId;
  @override
  List<Object?> get props => [playlistId, trackId];
}

class PlaylistBloc extends Bloc<PlaylistEvent, PlaylistState> {
  PlaylistBloc({
    required GetPlaylists getPlaylists,
    required CreatePlaylist createPlaylist,
    required AddTrackToPlaylist addTrack,
    required PlaylistRepository repository,
  })  : _getPlaylists = getPlaylists,
        _createPlaylist = createPlaylist,
        _addTrack = addTrack,
        _repository = repository,
        super(const PlaylistInitial()) {
    on<LoadPlaylists>(_onLoad);
    on<Create>(_onCreate);
    on<Delete>(_onDelete);
    on<AddTrack>(_onAddTrack);
    on<RemoveTrack>(_onRemoveTrack);
  }

  final GetPlaylists _getPlaylists;
  final CreatePlaylist _createPlaylist;
  final AddTrackToPlaylist _addTrack;
  final PlaylistRepository _repository;

  Future<void> _onLoad(
      LoadPlaylists event, Emitter<PlaylistState> emit) async {
    emit(const PlaylistLoading());
    try {
      emit(PlaylistLoaded(await _getPlaylists()));
    } catch (e) {
      emit(PlaylistError(e is Failure ? e.message : e.toString()));
    }
  }

  Future<void> _onCreate(Create event, Emitter<PlaylistState> emit) async {
    try {
      await _createPlaylist(event.name);
      add(const LoadPlaylists());
    } catch (e) {
      emit(PlaylistError(e is Failure ? e.message : e.toString()));
    }
  }

  Future<void> _onDelete(Delete event, Emitter<PlaylistState> emit) async {
    try {
      await _repository.deletePlaylist(event.id);
      add(const LoadPlaylists());
    } catch (e) {
      emit(PlaylistError(e is Failure ? e.message : e.toString()));
    }
  }

  Future<void> _onAddTrack(AddTrack event, Emitter<PlaylistState> emit) async {
    try {
      await _addTrack(event.playlistId, event.trackId);
      add(const LoadPlaylists());
    } catch (e) {
      emit(PlaylistError(e is Failure ? e.message : e.toString()));
    }
  }

  Future<void> _onRemoveTrack(
      RemoveTrack event, Emitter<PlaylistState> emit) async {
    try {
      await _repository.removeTrack(event.playlistId, event.trackId);
      add(const LoadPlaylists());
    } catch (e) {
      emit(PlaylistError(e is Failure ? e.message : e.toString()));
    }
  }
}
